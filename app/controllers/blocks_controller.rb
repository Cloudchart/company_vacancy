class BlocksController < ApplicationController
  def update_position
    # temporary created params[:blocks]. must be passed through ajax call.
    block = Block.find(params[:block_id])
    blocks = Block.where(section: block.section).order(:position).map(&:id)
    block_index = blocks.index(block.id)
    block_shift = params[:shift] == 'up' ? block_index - 1 : block_index + 1
    params[:blocks] = blocks.insert(block_shift, blocks.delete_at(block_index))
    # ---

    params[:blocks].each_with_index { |id, index| Block.update_all({position: index}, {uuid: id}) }
    redirect_to :back
  end

  def update_section
    Block.find(params[:block_id]).update_attribute(:section, params[:section])
  end

end
