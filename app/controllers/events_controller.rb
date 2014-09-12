class EventsController < ApplicationController
  before_action :set_company, only: [:index, :new, :create]  
  before_action :set_event, only: [:show, :edit, :update, :destroy, :verify]

  authorize_resource

  # GET /events
  def index
    @events = @company.events
  end

  # GET /events/1
  def show
    pagescript_params(
      can_update_event: can?(:update, @event),
      can_update_company: can?(:update, @event.company)
    )
  end

  # GET /events/new
  def new
    @event = @company.events.build
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  def create
    @event = @company.events.build(event_params)

    @event.author = current_user
    @event.should_build_objects!

    if @event.save
      Activity.track_activity(current_user, params[:action], @event)
      redirect_to @event, notice: 'Event was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /events/1
  def update
    if @event.update(event_params)
      Activity.track_activity(current_user, params[:action], @event)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /events/1
  def destroy
    company = @event.company
    @event.destroy
    redirect_to company_events_url(company), notice: 'Event was successfully destroyed.'
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

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :url, :location, :start_at, :end_at)
  end

end
