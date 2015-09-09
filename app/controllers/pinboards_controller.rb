class PinboardsController < ApplicationController
  include FollowableController

  before_action :set_pinboard, only: [:show, :settings, :update, :destroy]

  load_and_authorize_resource except: [:create, :show]

  after_action :create_intercom_event, only: :create
  after_action :call_page_visit_to_slack_channel, only: [:show, :index]

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
    @pinboard = pinboard_source.new(params_for_create)
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
    @pinboard.update!(params_for_update)

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

private

  def pinboard_source
    if current_user.editor?
      Pinboard
    else
      current_user.pinboards
    end
  end

  def params_for_create
    params.require(:pinboard).permit(:title, :user_id, :description, :access_rights, :suggestion_rights)
  end

  def params_for_update
    params_for_create
  end

  def set_pinboard
    @pinboard = Pinboard.find(params[:id])
  end

  def create_intercom_event
    return unless should_perform_sidekiq_worker? && @pinboard.valid?

    IntercomEventsWorker.perform_async('created-pinboard', current_user.id, pinboard_id: @pinboard.id)
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
