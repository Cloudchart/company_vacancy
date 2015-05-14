class AuthController < ApplicationController

  skip_before_action :verify_authenticity_token, only: :developer, if: -> { Rails.env.development? }

  layout 'guest'

  def failure
    render file: "#{Rails.root}/public/403.html", status: 200, layout: false
  end

  def twitter
    user = User.find_by(twitter: oauth_hash.info.nickname)

    if user && user.last_sign_in_at.blank?
      user.update_with_twitter_omniauth_hash(oauth_hash)
      SlackWebhooksWorker.perform_async('first_time_logged_in', user.id) if should_perform_sidekiq_worker?
    elsif user.nil?
      user = User.create_with_twitter_omniauth_hash(oauth_hash)
      SlackWebhooksWorker.perform_async('added_to_queue', user.id) if should_perform_sidekiq_worker?
    end

    authenticate_user!(user)
  end

  def developer
    if user = User.find_by_email(oauth_hash.info.email)
      authenticate_user!(user)
    else
      redirect_to :back
    end
  end

  def edit
    redirect_to main_app.root_path and return unless queued_user
    @user = queued_user
  end

  def update
    errors  = []

    user    = User.includes(:tokens).find(queued_user.try(:id))
    token   = Token.find_or_create_by(owner: user, name: :email_verification)
    email   = Email.new(address: params[:email])

    errors << :full_name  unless params[:full_name].present?
    errors << :email      unless email.valid? if params[:email].present? || token.data.present? && token.data[:address].present?

    raise ActiveRecord::RecordInvalid.new(user) unless errors.empty?

    User.transaction do
      user.touch
      user.update!(full_name: params[:full_name], company: params[:company], occupation: params[:occupation])
      token.update!(data: { address: email.address })
    end

    SlackWebhooksWorker.perform_async('added_details_to_queue', user.id) if should_perform_sidekiq_worker? && user.valid?

    render json: { id: user.id }

  rescue ActiveRecord::RecordInvalid

    render json: { id: user.id, errors: errors }, status: 422

  rescue ActiveRecord::RecordNotFound

    render json: { errors: [:user] }, status: 404

  end

private

  def authenticate_user!(user)
    warden_scope = user.authorized_at.present? ? :user : :queue

    warden.set_user(user, scope: warden_scope)
    cookies.signed[:user_id] = { value: user.id, expires: 2.weeks.from_now } if warden_scope == :user
    current_user.update(last_sign_in_at: Time.now) unless current_user.guest?

    redirect_to warden_scope == :user ? main_app.root_path : main_app.queue_path
  end

  def oauth_hash
    request.env['omniauth.auth']
  end

  def queued_user
    user = warden.user(:queue)
    user.present? && !user.authorized? ? user : nil
  end

end
