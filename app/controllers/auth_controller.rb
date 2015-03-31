class AuthController < ApplicationController

  skip_before_action :verify_authenticity_token, only: :developer, if: :development?

  layout 'landing'

  def twitter
    if user = User.find_by(twitter: oauth_hash.info.nickname)
      authenticate_user!(user)
    else
      authenticate_user!(User.create_with_twitter_omniauth_hash(oauth_hash))
    end
  end


  def developer
    if user = User.find_by_email(oauth_hash.info.email)
      authenticate_user!(user)
    end
  end


  def edit
    redirect_to main_app.root_path and return unless queued_user
    @user = queued_user
  end


  def update
    errors  = []
    user    = User.includes(:tokens).find(queued_user.id)
    token   = Token.find_or_create_by(owner: user, name: :email_verification)
    email   = CloudProfile::Email.new(address: params[:email])


    errors << :full_name  unless params[:full_name].present?
    errors << :email      unless email.valid? if params[:email].present? || token.data.present? && token.data[:address].present?

    raise ActiveRecord::RecordInvalid.new(user) unless errors.empty?

    User.transaction do
      user.touch
      user.update!(full_name: params[:full_name], company: params[:company], occupation: params[:occupation])
      token.update!(data: { address: email.address })
    end

    render json: { id: user.id }

  rescue ActiveRecord::RecordInvalid

    render json: { id: user.id, errors: errors }, status: 422
  end


  private


  def development?
    Rails.env.development?
  end


  def authenticate_user!(user)
    warden_scope = user.authorized_at.present? ? :user : :queue

    warden.set_user(user, scope: warden_scope)
    cookies.signed[:user_id] = { value: user.id, expires: 2.weeks.from_now } if warden_scope == :user

    redirect_to warden_scope == :user ? main_app.root_path : main_app.queue_path
  end


  def oauth_hash
    request.env['omniauth.auth']
  end

  def queued_user
    warden.user(:queue)
  end


end
