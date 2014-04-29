require_dependency "cloud_profile/application_controller"

module CloudProfile
  class UsersController < ApplicationController
    include TokenableController
    
    before_action :require_authenticated_user!, only: :activation_complete
    skip_before_action :require_properly_named_user!, only: :activation_complete


    # Registration form
    #
    def new
      store_return_path if params[:return_to].present? || !return_path_stored?
      @email = Email.new address: params[:email]
      @user  = User.new
    end
    

    # Registration
    #
    def create
      @email  = Email.new address: params[:email]
      @user   = User.new password: params[:password], password_confirmation: params[:password]

      @user.emails << @email
      #@user.should_validate_password!
      
      if @user.valid?
        token = Token.new name: 'registration', data: { email: @email.address, password_digest: @user.password_digest }
        token.save!
        ProfileMailer.activation_email(token).deliver
        redirect_to :register_complete
      else
        render :new
      end
    end
    
    
    def update
      current_user.update! params.require(:user).permit([:first_name, :last_name])
      render nothing: true
    end
    

    # Activation
    #
    def activation
      @token = Token.find(params[:token])
      @email = Email.new(address: @token.data[:email])
      
      raise ActiveRecord::RecordNotFound if @email.invalid?

      if request.post?
        @user = User.new(password_digest: @token.data[:password_digest])
        if @user.authenticate(params[:password])
          @user.emails << @email
          @user.save!
          @token.destroy
          warden.set_user(@user, scope: :user)
          redirect_to :root
        else
          @password_invalid = true
        end
      end
    end
    
    
    # Activation completion
    #
    def activation_complete
      render and return if request.get?
      current_user.update! params.require(:user).permit(:first_name, :last_name, avatar_attributes: [:image])
      redirect_to :settings
    rescue ActiveRecord::RecordInvalid
      render
    end
    

    def associate_with_person
      user = User.find(params[:id])
      token = Token.find(params[:token_id]) rescue nil

      if token
        person = Person.find(token.data)

        if user.people.map(&:company_id).include?(person.company_id)
          return redirect_to main_app.company_invite_path(token), alert: t('messages.company_invite.you_are_already_associated', name: person.company.name)
        end

        user.people << person
        user.save!
        clean_session_and_destroy_token(token)

        redirect_to main_app.company_path(person.company), notice: t('messages.invitation_completed')
      else
        redirect_to main_app.root_path, alert: t('messages.tokens.not_found', action: t('actions.company_invite'))
      end
    end

    
  end
end
