class PinsController < ApplicationController


  def index
    query = pin_source.includes(:parent)

    query = query.find(params[:ids]) if params[:ids]

    @pins = query

    respond_to do |format|
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
    pin = pin_source.create!(params_for_create)

    respond_to do |format|
      format.json { render json: { id: pin.uuid } }
    end

  rescue ActiveRecord::RecordInvalid

    respond_to do |format|
      format.json { render json: :nok, status: 412 }
    end
  end


  def update
    pin = pin_source.find(params[:id])

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
    current_user.is_editor? ? Pin : current_user.pins
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
    fields_for_create
  end


end
