class PinsController < ApplicationController
  include FollowableController

  before_filter :set_pin, except: :search

  authorize_resource

  after_action :call_page_visit_to_slack_channel, only: :show
  after_action :create_intercom_event, only: :create
  after_action :crawl_pin_origin, only: [:create, :update]

  def search
    query = params[:query].parameterize

    # TODO: use union
    pins_through_pinboard_tags = Pin.includes(:parent).joins(pinboard: :tags).where(tags: { name: query })
    pins_through_user_tags = Pin.includes(:parent).joins(user: :tags).where(tags: { name: query })

    @result = (pins_through_pinboard_tags + pins_through_user_tags).inject({}) do |memo, pin|
      insight = pin.insight? ? pin : pin.parent
      memo[insight.id] ||= {}
      memo[insight.id][:match_count] ||= 0
      memo[insight.id][:match_count] += 1
      memo[insight.id][:pin] = insight
      memo
    end.sort_by do |key, result|
      result[:match_count]
    end.reverse

    render 'sandbox/index'
  end

  def show
    respond_to do |format|
      format.html
      format.json
    end
  end

  def create
    @pin.update_by! current_user
    @pin.is_approved = true if autoapproval_granted?
    @pin.should_allow_domain_name! if current_user.editor?
    @pin.save!

    Activity.track(current_user, params[:action], @pin, { source: @pin.user })

    respond_to do |format|
      format.json { render json: { id: @pin.uuid } }
    end

  rescue ActiveRecord::RecordInvalid

    respond_to do |format|
      format.json { render json: { errors: @pin.errors }, status: 422 }
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
    ((current_user.roles.reject(&:owner_id).map(&:value) & %w(admin editor unicorn trustee)).any? ||
    @pin.is_suggestion? && can?(:update, @pin.pinboard))
  end

  def pin_source
    current_user.editor? && params_for_create[:user_id].present? ? Pin : current_user.pins
  end

  def set_pin
    @pin = case action_name
    when 'show'
      Pin.includes(:user, parent: :user).find(params[:id])
    when 'create'
      pin_source.new(params_for_create)
    else
      Pin.find(params[:id])
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
    params = default_fields << [:content, :pinnable_id, :pinnable_type, :parent_id, :origin, :is_suggestion]
    params << [:user_id] if current_user.editor?
    params
  end

  def fields_for_update
    params = default_fields << [:origin]
    params << [:user_id, :content] if current_user.editor?
    params
  end

  def crawl_pin_origin
    return unless should_perform_sidekiq_worker? && @pin.valid? && @pin.origin_uri
    DiffbotWorker.perform_async(@pin.id, @pin.class.name, :origin)
  end

  def create_intercom_event
    return unless should_perform_sidekiq_worker? && @pin.valid?

    event_name = if @pin.is_suggestion?
      'suggested-pin'
    elsif @pin.insight?
      'created-pin'
    elsif @pin.parent_id.present?
      'pinned-pin'
    end

    IntercomEventsWorker.perform_async(event_name, current_user.id, pin_id: @pin.id)
  end

  def call_page_visit_to_slack_channel
    post_page_visit_to_slack_channel('insight', main_app.insight_url(@pin),
      attachment: {
        title: @pin.source(:user).full_name,
        value: @pin.source(:content)
      }
    )
  end

end
