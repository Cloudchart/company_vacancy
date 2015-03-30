class BlocksController < ApplicationController


  def create
    owner = find_owner
    block = owner.blocks.build(block_params_for_create)
    authorize! :create, block
    
    block.save!

    blocks = owner.blocks.includes(:block_identities)
    
    respond_to do |format|
      format.json { render json: { blocks: blocks.active_model_serializer.new(blocks) } }
    end
  end


  def update
    block = Block.includes(:owner).find(params[:id])
    authorize! :update, block

    block.update!(block_params_for_update)

    block.reload

    respond_to do |format|
      format.json { render json: { block: block.active_model_serializer.new(block), identities: block.identities.active_model_serializer.new(block.identities) } }
    end
  end


  def destroy
    block = Block.includes(:owner).find(params[:id])
    authorize! :destroy, block
    
    block.destroy!
    
    owner = block.owner
    blocks = owner.blocks.includes(:block_identities)
    
    respond_to do |format|
      format.json { render json: { blocks: blocks.active_model_serializer.new(blocks) } }
    end
    
  end


  def reposition
    first_block = Block.find(params[:ids].first)
    authorize! :reposition, first_block

    Block.reposition(params[:ids])

    respond_to do |format|
      format.json { render json: { ok: 200 } }
    end
  end


private


  def find_owner
    params[:type].to_s.classify.constantize.find(params[:"#{params[:type]}_id"])
  end


  def block_params_for_create
    params.require(:block).permit(:section, :identity_type, :position, :kind)
  end
  

  def block_params_for_update
    params.require(:block).permit(
      :clear_identity_ids,
      identity_ids:             [],
      paragraphs_attributes:    [:id, :content],
      pictures_attributes:      [:id, :image],
      quotes_attributes:        [:id, :text, :person_id]
    )
  end

end
