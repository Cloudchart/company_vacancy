class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy, :verify]

  # GET /events
  def index
    @events = Event.all
  end

  # GET /events/1
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  def create
    @event = Event.new(event_params)

    if @event.save_with_buildings
      redirect_to @event, notice: 'Event was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /events/1
  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
    redirect_to events_url, notice: 'Event was successfully destroyed.'
  end

  def verify
    token = @event.token
    uri = URI.parse(@event.url)
    uri.path = "/cloudchart_event_verification_#{token.id}.txt"
    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      token.destroy
      redirect_to @event, message: t('messages.verifications.event.success')
    else
      redirect_to @event, alert: t('messages.verifications.event.fail')
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def event_params
    params.require(:event).permit(:name, :url, :location, :start_at, :end_at)
  end

end
