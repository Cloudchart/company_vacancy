class PinsController < ApplicationController

  after_action :create_intercom_event, only: :create


  def index
    respond_to do |format|
      format.html
      format.json
    end
  end


  def show
    @pin = pin_source.includes(:user, parent: :user).find(params[:id])

    respond_to do |format|
      format.json
    end
  end


  def create
    @pin = pin_source.new(params_for_create)

    @pin.update_by! current_user

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
    pin = pin_source.find(params[:id])

    pin.update_by! current_user

    pin.update!(params_for_update)

    respond_to do |format|
      format.json { render json: { id: pin.uuid }}
    end

  rescue ActiveRecord::RecordInvalid

    respond_to do |format|
      format.json { render json: :nok, status: 412 }
    end
  end


  def destroy
    pin = pin_source.find(params[:id])

    pin.destroy

    respond_to do |format|
      format.json { render json: { id: pin.uuid } }
    end
  end


  private


  def pin_source
    current_user.editor? ? Pin : current_user.pins
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
