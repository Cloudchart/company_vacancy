class PinboardsController < ApplicationController
  include FollowableController

  before_action :set_pinboard, only: [:show, :settings, :update, :destroy, :import_insights]

  load_and_authorize_resource except: [:create, :show]

  after_action :create_intercom_event, only: :create
  after_action :call_page_visit_to_slack_channel, only: [:show, :index]
  after_action :spread_notifications, only: :create

  def index
    respond_to do |format|
      format.html
      format.json
    end
  end

  def show
    redirect_to new_collection_invite_path and return if can?(:request_access, @pinboard)

    authorize! :read, @pinboard

    respond_to do |format|
      format.html
      format.json
    end
  end

  def create
    @pinboard = pinboard_source.new(pinboard_params)
    authorize! :create, @pinboard

    @pinboard.save!

    respond_to do |format|
      format.json { render json: { id: @pinboard.id } }
    end

  rescue ActiveRecord::RecordInvalid

    respond_to do |format|
      format.json { render json: :fail, status: 422 }
    end
  end

  def update
    @pinboard.update!(pinboard_params)

    respond_to do |format|
      format.json { render json: { id: @pinboard.id }}
    end

  rescue ActiveRecord::RecordInvalid

    respond_to do |format|
      format.json { render json: :fail, status: 422 }
    end
  end

  def destroy
    @pinboard.destroy

    respond_to do |format|
      format.json { render json: { id: @pinboard.id } }
    end
  end

  def import_insights
    dst_insight_ids = @pinboard.insight_ids
    src_insight_ids = Pinboard.find(params[:pinboard_id]).insight_ids

    (src_insight_ids - dst_insight_ids).each do |insight_id|
      @pinboard.pins.create(user: current_user, parent_id: insight_id, is_suggestion: true)
    end

    respond_to do |format|
      format.json { render json: { message: :ok }, status: 201 }
    end
  end

private

  def pinboard_source
    if current_user.editor?
      Pinboard
    else
      current_user.pinboards
    end
  end

  def pinboard_params
    params.require(:pinboard).permit(:title, :user_id, :description, :access_rights, :suggestion_rights, :tag_names)
  end

  def set_pinboard
    @pinboard = Pinboard.find(params[:id])
  end

  def create_intercom_event
    return unless should_perform_sidekiq_worker? && @pinboard.valid?

    IntercomEventsWorker.perform_async('created-pinboard', current_user.id, pinboard_id: @pinboard.id)
  end

  def spread_notifications
    ActiveSupport::Notifications.instrument('pinboards#create', id: @pinboard.id)
  end

  def call_page_visit_to_slack_channel
    case action_name
    when 'index'
      page_title = 'collections list'
      page_url = main_app.collections_url
    when 'show'
      page_title = "#{@pinboard.title} collection"
      page_url = main_app.collection_url(@pinboard)
    end

    post_page_visit_to_slack_channel(page_title, page_url)
  end

end
