require_dependency "cloud_profile/application_controller"

module CloudProfile
  class UsersController < ApplicationController


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
    
    
  end
end
