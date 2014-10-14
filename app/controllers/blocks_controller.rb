class BlocksController < ApplicationController
  authorize_resource


  def create
    owner = find_owner
    block = owner.blocks.create!(block_params_for_create)

    Activity.track_activity(current_user, params[:action], block, owner)
    
    blocks = owner.blocks.includes(:block_identities)
    
    respond_to do |format|
      format.json { render json: { blocks: blocks.active_model_serializer.new(blocks) } }
    end
  end


  def update
    @block = Block.includes(:owner).find(params[:id])
    #@block.should_destroy_previous_block_images! if @block.identity_type == 'BlockImage' && @block.block_images.any?
    @block.update!(block_params_for_update)

    Activity.track_activity(current_user, params[:action], @block, @block.owner)

    respond_to do |format|
      format.html { redirect_to @block.owner }
      format.js
      format.json { render json: { block: @block.active_model_serializer.new(@block), identities: @block.identities.active_model_serializer.new(@block.identities) } }
    end
  end


  def destroy
    block = Block.includes(:owner).find(params[:id])
    owner = block.owner

    authorize! :destroy, block
    block.destroy!
    
    blocks = owner.blocks.includes(:block_identities)
    
    respond_to do |format|
      format.json { render json: { blocks: blocks.active_model_serializer.new(blocks) } }
    end
    # block = Block.includes(:owner, { block_identities: :identity }).find(params[:id])
    # authorize! :destroy, block
    # block.destroy
    #
    # respond_to do |format|
    #   format.html { redirect_to block.owner }
    #   format.json { render json: block.owner.blocks_by_section(block.section), each_serializer: BlockEditorSerializer, root: false }
    # end
  end


  def update_position
    # temporary created params[:blocks]. must be passed through ajax call.
    block = Block.find(params[:block_id])
    block_ids = Block.where(section: block.section).order(:position).map(&:id)
    block_index = block_ids.index(block.id)
    shifted_index = params[:shift] == 'up' ? block_index - 1 : block_index + 1
    params[:blocks] = block_ids.insert(shifted_index, block_ids.delete_at(block_index))
    # ---

    params[:blocks].each_with_index { |id, index| Block.update_all({ position: index + 1 }, { uuid: id }) }
    redirect_to :back
  end


private


  def find_owner
    case params[:type]
    when :company
      Company.find(params[:company_id])
    end
  end


  def block_params_for_create
    params.require(:block).permit(:section, :identity_type, :position)
  end
  

  def block_params_for_update
    params.require(:block).permit(
      :clear_identity_ids,
      identity_ids:             [],
      paragraphs_attributes:    [:id, :content],
      pictures_attributes:      [:id, :image]
    )
  end

end
