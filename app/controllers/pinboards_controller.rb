class PinboardsController < ApplicationController


  def index
    respond_to do |format|
      format.html
      format.json
    end
  end


  def show
    @pinboard = Pinboard.find(params[:id])

    respond_to do |format|
      format.html
      format.json
    end
  end


  def settings
    @pinboard = effective_user.pinboards.find(params[:id])

    respond_to do |format|
      format.html
    end
  end


  def create
    pinboard = effective_user.pinboards.create!(params_for_create)

    respond_to do |format|
      format.json { render json: { id: pinboard.uuid } }
    end

  rescue ActiveRecord::RecordInvalid

    respond_to do |format|
      format.json { render json: :fail, status: 422 }
    end
  end


  def update
    pinboard = effective_user.pinboards.find(params[:id])

    pinboard.update!(params_for_update)

    respond_to do |format|
      format.json { render json: { id: pinboard.uuid }}
    end

  rescue ActiveRecord::RecordInvalid

    respond_to do |format|
      format.json { render json: :fail, status: 422 }
    end
  end


  def destroy
    pinboard = effective_user.pinboards.find(params[:id])

    pinboard.destroy

    respond_to do |format|
      format.json { render json: { id: pinboard.uuid } }
    end
  end


  private


  def effective_user
    current_user
  end


  def params_for_create
    params.require(:pinboard).permit(:title, :description, :access_rights)
  end


  def params_for_update
    params_for_create
  end


end
