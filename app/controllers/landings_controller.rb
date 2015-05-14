class LandingsController < ApplicationController

  before_action :set_user, only: :create
  before_action :set_landing, only: [:create, :show, :update, :destroy]

  load_and_authorize_resource

  before_action :check_existing_landing, only: :create
  before_action :call_page_visit_to_slack_channel, only: :show

  def show
    respond_to do |format|
      format.html
      format.json
    end
  end

  def create
    @landing.author = current_user

    if @landing.save
      respond_to do |format|
        format.json { render json: { id: @landing.id } }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @landing.errors }, status: 422 }
      end
    end
  end

  def update
    if @landing.update(landing_params)
      respond_to do |format|
        format.json { render json: { id: @landing.id } }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @landing.errors }, status: 422 }
      end
    end
  end

  def destroy
    @landing.destroy

    respond_to do |format|
      format.json { render json: { id: @landing.id } }
    end
  end

private

  def set_user
    @user = User.friendly.find(params[:user_id])
  end

  def set_landing
    @landing = if action_name == 'create'
      @user.landings.build
    else
      Landing.friendly.find(params[:id])
    end
  end

  def landing_params
    params.require(:landing).permit(:title, :image, :body)
  end

  def check_existing_landing
    if existing_landing = @user.landings.find_by(author: current_user)
      respond_to do |format|
        format.json { render json: { id: existing_landing.id } }
      end and return
    end
  end

  def call_page_visit_to_slack_channel
    page_title = if current_user == @landing.user
      'his personal landing page'
    else
      "#{@landing.user.full_name_or_twitter}'s personal landing page"
    end

    post_page_visit_to_slack_channel(page_title, main_app.landing_url(@landing))
  end

end
