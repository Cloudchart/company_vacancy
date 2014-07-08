class BlocksController < ApplicationController
  authorize_resource

  def create
    %w(company event vacancy).each do |name|
      @object = name.classify.constantize.find(params[:"#{name}_id"]) if params[:"#{name}_id"].present?
    end

    @block = @object.blocks.create!(block_params_for_create)
    Activity.track_activity(current_user, params[:action], @block, @block.owner)

    respond_to do |format|
      format.html { redirect_to @block.owner }
      format.js
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
      format.json { render json: @block, serializer: BlockEditorSerializer, root: false }
    end
  end

  def destroy
    block = Block.includes(:owner, { block_identities: :identity }).find(params[:id])
    authorize! :destroy, block
    block.destroy
    redirect_to block.owner
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

  def update_section
    Block.find(params[:block_id]).update_attribute(:section, params[:section])
  end

private

  def block_params_for_create
    params.require(:block).permit(:section, :identity_type, :position)
  end
  
  def block_params_for_update
    params.require(:block).permit(
      identity_ids:             [],
      paragraphs_attributes:    [:id, :content],
      block_images_attributes:  [:id, :image]
    )
  end

end
