module Companies
  class InvitesController < ApplicationController

    before_action :set_company, only: [:create]
    before_action :set_token, only: [:show, :accept, :destroy, :resend]

    authorize_resource class: :invite, except: [:create, :resend]

    after_action :create_intercom_event, only: :create

    # Show
    #
    def show
      # simulate the exception if token is locked with specific user
      if @token.data[:user_id].present? && @token.data[:user_id] != current_user.id
        raise ActiveRecord::RecordNotFound
      end

      @company = @token.owner
      @author = @company.owner

      pagescript_params(
        author_full_name: @author.full_name,
        author_avatar_url: @author.avatar.try(:url),
        token: TokenSerializer.new(@token).as_json
      )
    end
    
    # Create
    #
    def create
      authorize! :manage_company_invites, @company

      @token = Token.new params.require(:token).permit(data: [:email, :role] ).merge(name: 'invite', owner: @company)
      @token.save!

      respond_to do |format|
        format.json { render json: @token, root: :token }
      end

      @email = CloudProfile::Email.find_by(address: @token.data[:email]) || @token.data[:email]
      
      UserMailer.company_invite(@email, @token).deliver

    rescue ActiveRecord::RecordInvalid
      
      respond_to do |format|
        format.json { render json: @token, root: :token, status: 412 }
      end
    end

    # Resend
    #
    def resend
      company = @token.owner
      authorize! :manage_company_invites, company

      token = company.tokens.where(name: :invite).find(params[:id])
      UserMailer.company_invite(token.data[:email], token).deliver

      respond_to do |format|
        format.json { render json: token, root: :token }
      end
    end

    # Accept
    # 
    def accept
      role = current_user.roles.create!(value: @token.data[:role], owner: @token.owner)
      favorite = current_user.favorites.find_by(favoritable_id: @token.owner_id).try(:delete)
      @token.destroy

      respond_to do |format|
        format.html { redirect_to cloud_profile.companies_path }
        format.json { 
          render json: { 
            role: role,
            favorite: favorite,
            company: CompanySerializer.new(@token.owner, scope: current_user)
          }
        }
      end
    end
    
    # Destroy
    #
    def destroy
      @token.destroy
      
      respond_to do |format|
        format.html { redirect_to cloud_profile.root_path }
        format.json { render json: @token, root: :token }
      end
    end

  private

    def set_company
      @company = Company.find(params[:company_id])
    end

    def set_token
      @token = Token.find(params[:id])
    end

    def create_intercom_event
      return unless should_perform_sidekiq_worker? && @token.valid?

      IntercomEventsWorker.perform_async('invited-person',
        current_user.id,
        token_id: @token.id,
        user_id: @email.try(:user_id)
      )
    end
  
  end
end
