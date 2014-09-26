class TagsController < ApplicationController
  authorize_resource
  
  def index
    tags = Tag.where(is_acceptable: true).all

    respond_to do |format|
      format.json { render json: { tags: tags.active_model_serializer.new(tags) }}
    end
  end
  
  def create
    tag = Tag.where(name: params.require(:tag)[:name].parameterize).first_or_create!
    
    respond_to do |format|
      format.json { render json: { tag: tag }}
    end

  rescue ActiveRecord::RecordInvalid

    respond_to do |format|
      format.json { render json: {}, status: 412 }
    end
  end
  
end
