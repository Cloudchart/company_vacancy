class InvitesController < ApplicationController

  authorize_resource class: :invite
  before_action :call_page_visit_to_slack_channel, only: :index
  after_action :create_intercom_event, only: :create

  def index
    respond_to do |format|
      format.html
    end
  end

  def create
    @user = User.new(user_params)
    @user.should_validate_twitter_handle_for_invite!
    @user.should_create_tour_tokens!
    @user.should_create_unicorn_role! if has_rights_to_assign_unicorn?
    @user.authorized_at = Time.now

    if @user.save
      Activity.track(current_user, 'invite', @user)

      respond_to do |format|
        format.json { render json: { id: @user.uuid } }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @user.errors }, status: 422 }
      end
    end
  end

  def email
    @user = User.find(params[:id])
    @email_template = EmailTemplate.new(email_template_params)

    if @email_template.valid?
      UserMailer.custom_invite(@user, @email_template, current_user).deliver
      Activity.track(current_user, 'email_invite', @user, data: {
        subject: @email_template.subject,
        body:    @email_template.body,
        email:   @email_template.email
      })

      respond_to do |format|
        format.json { render json: :ok }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @email_template.errors }, status: 422 }
      end
    end
  end

private

  def user_params
    params.require(:user).permit(:twitter)
  end

  def email_template_params
    params.require(:email_template).permit(:email, :subject, :body)
  end

  def has_rights_to_assign_unicorn?
    params[:user].try(:[], :is_unicorn) == '1' && current_user.editor?
  end

  def create_intercom_event
    return unless should_perform_sidekiq_worker? && @user.valid?

    IntercomEventsWorker.perform_async('invited-user-to-app',
      current_user.id,
      user_id: @user.id
    )
  end

  def call_page_visit_to_slack_channel
    post_page_visit_to_slack_channel('Invites page', main_app.invites_url)
  end

end
