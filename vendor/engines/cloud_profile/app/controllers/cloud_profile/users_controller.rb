require_dependency "cloud_profile/application_controller"

module CloudProfile
  class UsersController < ApplicationController
    before_action :require_authenticated_user!, only: :activation_complete
    skip_before_action :require_properly_named_user!, only: :activation_complete
    
    # Request invite
    #
    def invite
      user = User.new params.require(:user).permit(:email, :full_name)
      user.password = user.password_confirmation = 'dummy'
      
      if user.valid?
        Token.transaction do
          tokens = Token.where(name: :request_invite).select { |token| token.data && token.data[:email] == user.email }.each(&:destroy)
          token = Token.create name: :request_invite, data: { full_name: user.full_name, email: user.email }
          UserMailer.thanks_for_invite_request(token).deliver
        end
        
        respond_to do |format|
          format.json { render json: { state: :ok } }
        end
        
      else

        respond_to do |format|
          format.json { render json: { errors: user.errors.keys }, status: 403 }
        end

      end
    end


    # Registration form
    #
    def new
      store_return_path if params[:return_to].present? || !return_path_stored?
      @email = Email.new address: params[:email]
      @user  = User.new
    end
    

    # Registration
    # params: email, full_name, password, password_confirmation, invite
    #
    def create
      user = User.new params.require(:user).permit(:email, :full_name, :password, :password_confirmation, :invite)
      
      user.should_validate_invite!
      
      if user.valid?
        
        if user.invite.data && user.invite.data[:email] == user.email
          # Register and login

          user.save!
          user.invite.destroy
          warden.set_user(user, scope: :user)

          respond_to do |format|
            format.json { render json: { state: :login }}
          end
        else
          # Send activation email

          token = Token.create(name: :registration, data: { full_name: user.full_name, address: user.email, password_digest: user.password_digest })
          ProfileMailer.activation_email(token).deliver

          respond_to do |format|
            format.json { render json: { state: :activation }}
          end
        end
        
      else
        respond_to do |format|
          format.json { render json: { errors: user.errors.keys }, status: 403 }
        end
      end
      
      #@email  = Email.new address: params[:email]
      #@user   = User.new password: params[:password], password_confirmation: params[:password]

      #@user.emails << @email
      
      #if @user.valid?
      #  token = Token.new name: 'registration', data: { address: @email.address, password_digest: @user.password_digest }
      #  token.save!
      #  ProfileMailer.activation_email(token).deliver
      #  redirect_to :register_complete
      #else
      #  render :new
      #end
    end
    
    
    def update
      current_user.should_validate_name!
      current_user.update! params.require(:user).permit([:full_name, :avatar, :remove_avatar])

      respond_to do |format|
        format.json { render json: current_user, only: [:full_name, :avatar_url], serializer: PersonalSerializer, root: false }
      end
    
    rescue ActiveRecord::RecordInvalid
      render json: current_user.errors, status: 422
    end
    

    # Activation
    #
    def activation
      token = Token.find(params[:token])
      email = Email.new(address: token.data[:address])
      raise ActiveRecord::RecordNotFound if email.invalid?
      
      user = User.new(full_name: token.data[:full_name] || '', password_digest: token.data[:password_digest])
      user.emails << email
      user.save!
      token.destroy
      warden.set_user(user, scope: :user)

      redirect_to main_app.root_path
    end
    
    
    def activation_
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
        format.html { redirect_to main_app.new_company_path }
        format.json do
          if current_user.has_proper_name?
            render json: { redirect_to: main_app.new_company_path }
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

  private
  
    def render_user_json
      render json: current_user, serializer: CloudProfile::UserSerializer, root: false
    end
    
  end
end
