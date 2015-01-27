class PinsController < ApplicationController
  
  
  def index
    query = current_user.pins.includes(:parent)
    
    query = query.find(params[:ids]) if params[:ids]
    
    @pins = query
    
    respond_to do |format|
      format.json
    end
  end
  
  
  def show
    @pin = current_user.pins.includes(:parent).find(params[:id])
    
    respond_to do |format|
      format.json
    end
  end
  
  
  def create
    pin = current_user.pins.create!(params_for_create)
    
    respond_to do |format|
      format.json { render json: { id: pin.uuid } }
    end
  
  rescue ActiveRecord::RecordInvalid
    
    respond_to do |format|
      format.json { render json: :nok, status: 412 }
    end
  end
  
  
  def destroy
    pin = current_user.pins.find(params[:id])
    
    pin.destroy
    
    respond_to do |format|
      format.json { render json: { id: pin.uuid } }
    end
  end
  
  
  private
  
  
  def params_for_create
    params.require(:pin).permit(:pinnable_id, :pinnable_type, :pinboard_id, :content, :parent_id)
  end
  
  
end
