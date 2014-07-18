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
        token = Token.new name: 'registration', data: { address: @email.address, password_digest: @user.password_digest }
        token.save!
        ProfileMailer.activation_email(token).deliver
        redirect_to :register_complete
      else
        render :new
      end
    end
    
    
    def update
      current_user.update! params.require(:user).permit([:name, :first_name, :last_name])
      render nothing: true
    end
    

    # Activation
    #
    def activation
      @token = Token.find(params[:token])
      @email = Email.new(address: @token.data[:address])
      
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

      respond_to do |format|
        format.html
        format.json { render_user_json }
      end and return if request.get?

      current_user.update! params.require(:user).permit(:full_name, :avatar)

      respond_to do |format|
        format.html { redirect_to main_app.companies_path }
        format.json do
          if current_user.has_proper_name?
            render json: { redirect_to: main_app.companies_path }
          else
            render_user_json
          end
        end
      end

    rescue ActiveRecord::RecordInvalid

      respond_to do |format|
        format.html
        format.json { render_user_json }
      end

    end
    

    def associate_with_person
      user = User.find(params[:id])
      token = Token.find(params[:token_id]) rescue nil

      if token
        person = Person.find(token.data)

        if user.people.map(&:company_id).include?(person.company_id)
          return redirect_to main_app.company_invite_path(token), alert: t('messages.company_invite.you_are_already_associated', name: person.company.name)
        end

        # create subscription (only to vacancies and events so far)
        user.subscriptions.find_by(subscribable: person.company).try(:destroy)
        user.subscriptions.create!(subscribable: person.company, types: [:vacancies, :events])

        user.people << person
        user.save!
        clean_session_and_destroy_token(token)

        redirect_to main_app.company_path(person.company), notice: t('messages.invitation_completed')
      else
        redirect_to main_app.root_path, alert: t('messages.tokens.not_found', action: t('actions.company_invite'))
      end
    end


  private
  
    def render_user_json
      render json: current_user, serializer: CloudProfile::UserSerializer, root: false
    end
    
  end
end
