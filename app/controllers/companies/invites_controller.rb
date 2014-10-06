module Companies
  class InvitesController < ApplicationController
    before_action :set_company, only: [:index, :create, :resend]
    before_action :set_token, only: [:show, :accept, :destroy]

    authorize_resource class: :company_invite, except: [:index, :create, :resend]
    
    # List
    #
    def index
      authorize! :manage_company_invites, @company

      respond_to do |format|
        format.json { render json: { tokens: @company.invite_tokens } }
      end
    end
    

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

      token = Token.new params.require(:token).permit(data: [:email, :role] ).merge(name: 'invite', owner: @company)
      token.save!
      
      respond_to do |format|
        format.json { render json: token, root: :token }
      end
      
      UserMailer.company_invite(token.data[:email], token).deliver

    rescue ActiveRecord::RecordInvalid
      
      respond_to do |format|
        format.json { render json: token, root: :token, status: 412 }
      end
    end

    # Resend
    #
    def resend
      authorize! :manage_company_invites, @company

      token = @company.tokens.where(name: :invite).find(params[:id])
      UserMailer.company_invite(token.data[:email], token).deliver

      respond_to do |format|
        format.json { render json: token, root: :token }
      end
    end

    # Accept
    # 
    def accept
      current_user.roles.create!(value: @token.data[:role], owner: @token.owner)
      @token.destroy

      redirect_to cloud_profile.root_path
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
  
  end
end

# class CompanyInvitesController < ApplicationController
#   before_action :set_token, only: [:show, :accept, :destroy]

#   authorize_resource class: false, except: :create

#   def show
#     @company = @token.owner
#     @author = User.find(@token.data[:author_id])

#     pagescript_params(
#       author_full_name: @author.full_name,
#       author_avatar_url: @author.avatar.try(:url),
#       token: TokenSerializer.new(@token).as_json
#     )
#   end

#   def create
#     person = Person.find(params[:person_id])
#     authorize! :create_company_invite, person.company

#     address = person.email.present? ? person.email : params[:email]

#     email = CloudProfile::Email.find_by(address: address)

#     if email && email.user.people.map(&:company_id).include?(person.company_id)
#       respond_to do |format|
#         format.json { render json: t('messages.company_invite.user_has_already_been_associated'), status: 412 }
#       end
#     else
#       email = email || address

#       create_invite_token_and_send_email(person, email, { make_owner: params[:make_owner] })

#       respond_to do |format|
#         format.json { render json: { owner_invites: owner_invites(person.company) } }
#       end
#     end
#   end

#   def accept
#     person = Person.find(@token.data[:person_id])

#     unless current_user.people.map(&:company_id).include?(person.company_id)
#       person.update(is_company_owner: true) if @token.data[:make_owner]
#       current_user.people << person
      
#       # TODO: add default subscription
#       # current_user.subscriptions.find_by(subscribable: person.company).try(:destroy)
#       # current_user.subscriptions.create!(subscribable: person.company, types: [:vacancies, :events])

#       @token.destroy
#     end

#     redirect_to cloud_profile.root_path
#   end

#   def destroy
#     @token.destroy

#     respond_to do |format|
#       format.html { redirect_to cloud_profile.root_path }
#       format.json { render json: { owner_invites: owner_invites(@token.owner) } }
#     end
#   end

# private

#   def set_token
#     @token = Token.find(params[:id])
#   end

#   def owner_invites(company)
#     company.invite_tokens.map do |token|
#       { uuid: token.id, full_name: token.data[:full_name], person_id: token.data[:person_id] }
#     end
#   end

#   def create_invite_token_and_send_email(person, email, options={})
#     options[:make_owner] = options[:make_owner].present?
#     address = email.try(:address) || email

#     token = Token.where(name: :invite, owner: person.company).select { |token| token.data[:person_id] == person.id }.first

#     unless token
#       token = Token.create!(
#         name: :invite,
#         owner: person.company,
#         data: {
#           author_id: current_user.id,
#           person_id: person.id,
#           user_id: email.try(:user_id),
#           full_name: person.full_name,
#           email: address,
#           make_owner: options[:make_owner] # role mask will be here
#         }
#       )

#       if email.try(:user)
#         Activity.track_activity(current_user, 'invite', email.user, token.owner)
#         Activity.track_activity(current_user, 'invite', email.user, token.owner, email.user_id)
#       end
#     end

#     UserMailer.company_invite(email, token).deliver
#   end

# end
