require_dependency "cloud_profile/application_controller"

module CloudProfile
  class UsersController < ApplicationController    
    authorize_resource class: :cloud_profile_user, only: :update
    
    
    # show
    #
    def show
      @user = current_user
      
      respond_to do |format|
        format.json
      end
    end


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
      if (params[:invite] && !user_authenticated?)
        invite = Token.find(params[:invite])

        # sign up is allowed only for cc and company tokens
        unless invite.owner_type.blank? || invite.owner_type == 'Company'
          redirect_to main_app.root_path and return
        end

        store_return_path if params[:return_to].present? || !return_path_stored?

        user = User.new(full_name: "some", invite: invite)
        pagescript_params(invite: invite, email: user.invite.data.try(:[], :email), full_name: user.invite.data.try(:[], :full_name))
      else
        redirect_to main_app.root_path
      end
    end
    

    # Registration
    # params: email, full_name, password, password_confirmation, invite
    #
    def create
      user = User.new params.require(:user).permit(:email, :full_name, :password, :password_confirmation, :invite)
      
      user.should_validate_invite!
      user.should_validate_name!
      
      if user.valid?
        
        if user.invite.data && user.invite.data[:email] == user.email
          # Activate and login
          # 
          user.save!

          if user.invite.owner.instance_of?(Company)
            user.invite.update(data: user.invite.data.merge({ user_id: user.id }) )
          else
            user.invite.destroy
          end
          
          warden.set_user(user, scope: :user)

          respond_to do |format|
            format.json { render json: { state: :login, previous_path: previous_path }}
          end
        else
          # Create activation token and send email
          # 
          token = Token.create(
            name: :activation,
            data: { 
              full_name: user.full_name,
              address: user.email,
              password_digest: user.password_digest,
              invite_id: user.invite.id
            }
          )

          ProfileMailer.activation_email(token).deliver
          SlackWebhooksWorker.perform_async(
            text: t('user.activities.started_to_sign_up', name: user.full_name, email: user.email)
          ) if should_perform_sidekiq_worker?

          respond_to do |format|
            format.json { render json: { state: :activation }}
          end
        end
        
      else
        respond_to do |format|
          format.json { render json: { errors: user.errors }, status: 403 }
        end
      end
      
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

    def check_invite
      token = Token.find_by_rfc1751(params[:invite])

      if token
        respond_to do |format|
          format.json { render json: { state: :register } }
        end
      else
        respond_to do |format|
          format.json { render json: { errors: [:invite] }, status: 422 }
          # TODO: add error message
          # { invite: "Sorry. We didn't find this code." }
        end
      end
    end
    

    # Activation
    #
    def activation
      token = Token.find(params[:token])

      # destroy token if invite could not be found
      # 
      begin
        invite_token = Token.find(token.data[:invite_id])
        
      rescue ActiveRecord::RecordNotFound
        token.destroy
        return redirect_to main_app.root_path, alert: t('errors.messages.invite_not_found')
      end

      email = Email.new(address: token.data[:address])
      raise ActiveRecord::RecordNotFound if email.invalid?

      user = User.new(full_name: token.data[:full_name] || '', password_digest: token.data[:password_digest])
      user.emails << email
      user.save!

      token.destroy

      warden.set_user(user, scope: :user)

      if invite_token.owner.instance_of?(Company)
        invite_token.data[:user_id] = user.id
        invite_token.save

        redirect_to main_app.company_invite_url(invite_token.owner, invite_token)
      else
        invite_token.destroy

        redirect_to main_app.root_path
      end

    end

  end
end
