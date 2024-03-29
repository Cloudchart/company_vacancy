class PinsController < ApplicationController

  before_filter :set_pin

  authorize_resource

  after_action :call_page_visit_to_slack_channel, only: :show
  after_action :create_intercom_event, only: :create

  def show
    respond_to do |format|
      format.html
      format.json
    end
  end


  def create
    @pin.update_by! current_user
    @pin.is_approved = true if autoapproval_granted?
    @pin.author = current_user if should_assign_author?
    @pin.user = @pin.parent.user if @pin.is_suggestion
    @pin.should_allow_domain_name! if current_user.editor?
    @pin.save!

    Activity.track(current_user, params[:action], @pin, { source: @pin.user })

    respond_to do |format|
      format.json { render json: { id: @pin.uuid } }
    end

  rescue ActiveRecord::RecordInvalid

    respond_to do |format|
      format.json { render json: :nok, status: 412 }
    end
  end

  def update
    @pin.update_by! current_user
    @pin.should_allow_domain_name! if current_user.editor?
    @pin.update!(params_for_update)

    respond_to do |format|
      format.json { render json: { id: @pin.id }}
    end

  rescue ActiveRecord::RecordInvalid

    respond_to do |format|
      format.json { render json: :nok, status: 412 }
    end
  end

  def destroy
    @pin.destroy

    respond_to do |format|
      format.json { render json: { id: @pin.id } }
    end
  end

  def approve
    @pin.update(is_approved: true)

    respond_to do |format|
      format.json { render json: { id: @pin.id }}
    end
  end

private

  def autoapproval_granted?
    @pin.content.present? &&
    (current_user.roles.reject(&:owner_id).map(&:value) & %w(admin editor unicorn trustee)).any?
  end

  def pin_source
    current_user.editor? ? Pin : current_user.pins
  end

  def set_pin
    @pin = case action_name
    when 'show'
      Pin.includes(:user, parent: :user).find(params[:id])
    when 'create'
      pin_source.new(params_for_create)
    else
      pin_source.find(params[:id])
    end
  end

  def params_for_create
    params.require(:pin).permit(fields_for_create)
  end

  def params_for_update
    params.require(:pin).permit(fields_for_update)
  end

  def default_fields
    params = [:pinboard_id]
  end

  def fields_for_create
    params = default_fields << [:content, :pinnable_id, :pinnable_type, :parent_id, :origin]
    params << [:user_id, :is_suggestion] if current_user.editor?
    params
  end

  def fields_for_update
    params = default_fields << [:origin]
    params << [:user_id, :content] if current_user.editor?
    params
  end

  def should_assign_author?
    current_user.editor? && (@pin.pinnable.blank? || @pin.is_suggestion)
  end

  def create_intercom_event
    return unless should_perform_sidekiq_worker? && @pin.valid?

    event_name = if @pin.pinnable_type == 'Post' && @pin.parent.blank?
      'pinned-post'
    elsif @pin.pinnable_type == 'Post' && @pin.parent.present?
      'pinned-post-pin'
    end

    IntercomEventsWorker.perform_async(event_name, current_user.id, pin_id: @pin.id)
  end

  def call_page_visit_to_slack_channel
    post_page_visit_to_slack_channel('Insight page', main_app.insight_url(@pin))
  end

end
