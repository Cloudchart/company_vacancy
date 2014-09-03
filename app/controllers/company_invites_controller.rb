class CompanyInvitesController < ApplicationController
  skip_before_action :require_authenticated_user!
  before_action :require_authenticated_user!, only: [:accept, :destroy]
  before_action :set_token, only: [:show, :accept, :destroy]

  def show
    @company = @token.owner
    @author = User.find(@token.data[:author_id])

    pagescript_params(
      author_full_name: @author.full_name,
      author_avatar_url: @author.avatar.try(:url),
      token: TokenSerializer.new(@token).as_json
    )
  end

  def create
    person = Person.find(params[:person_id])

    person.update(email: params[:email]) if person.email.blank? && params[:email].present?

    email = CloudProfile::Email.find_by(address: person.email)

    if email && email.user.people.map(&:company_id).include?(person.company_id)
      respond_to do |format|
        format.json { render json: { message: t('messages.company_invite.user_has_already_been_associated') } }
      end
    else
      create_invite_token_and_send_email(person, email, { make_owner: params[:make_owner] })

      respond_to do |format|
        format.json { render json: { owner_invites: owner_invites(person.company) } }
      end
    end
  end

  def accept
    person = Person.find(@token.data[:person_id])

    unless current_user.people.map(&:company_id).include?(person.company_id)
      person.update(is_company_owner: true) if @token.data[:make_owner]
      current_user.people << person
      
      # TODO: add default subscription
      # current_user.subscriptions.find_by(subscribable: person.company).try(:destroy)
      # current_user.subscriptions.create!(subscribable: person.company, types: [:vacancies, :events])

      @token.destroy
    end

    redirect_to cloud_profile.root_path
  end

  def destroy
    @token.destroy

    respond_to do |format|
      format.html { redirect_to cloud_profile.root_path }
      format.json { render json: { owner_invites: owner_invites(@token.owner) } }
    end
  end

private

  def set_token
    @token = Token.find(params[:id])
  end

  def owner_invites(company)
    company.invite_tokens.map do |token|
      Person.find(token.data[:person_id]).attributes.merge(invite: token.id)
    end
  end

  def create_invite_token_and_send_email(person, email, options={})
    options[:make_owner] = options[:make_owner].present?
    email = email || person.email

    token = Token.where(name: :invite, owner: person.company).select { |token| token.data[:person_id] == person.id }.first

    unless token
      token = Token.create!(
        name: :invite,
        owner: person.company,
        data: {
          author_id: current_user.id,
          person_id: person.id,
          full_name: person.full_name,
          email: person.email,
          make_owner: options[:make_owner] # role mask will be here
        }
      )
    end

    UserMailer.company_invite(email, token).deliver
  end

end
