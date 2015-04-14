class PinsController < ApplicationController

  before_filter :set_pin, except: :index

  authorize_resource

  after_action :create_intercom_event, only: :create

  def index
    respond_to do |format|
      format.html
      format.json
    end
  end

  def show
    respond_to do |format|
      format.json
    end
  end

  def create
    @pin.update_by! current_user

    if (current_user.admin? || current_user.editor? || current_user.unicorn?) && @pin.content.present?
      @pin.is_approved = true
    end

    @pin.save!

    Activity.track(current_user, params[:action], @pin, @pin.user)

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

  def pin_source
    current_user.editor? ? Pin : current_user.pins
  end

  def set_pin
    @pin = case action_name
    when 'show'
      pin_source.includes(:user, parent: :user).find(params[:id])
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

  def fields_for_create
    [:user_id, :pinnable_id, :pinnable_type, :pinboard_id, :content, :parent_id]
  end

  def fields_for_update
    if current_user.editor?
      fields_for_create
    else
      fields_for_create - [:user_id] 
    end
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

end
