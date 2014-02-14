class BlocksController < ApplicationController
  before_filter :find_company, only: [:create]

  def create
    @company.blocks << Block.new({section: params[:section], identity_type: params[:identity_type]})
    redirect_to @company
  end
  
  def update
    block = Block.includes(:owner).find(params[:id])
    block.update_attributes! block_params
    redirect_to block.owner
  end
  
  def destroy
    block = Block.includes(:owner, { block_identities: :identity }).find(params[:id])
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

protected  
  
  def find_company
    @company = Company.find params[:company_id]
  end

  def block_params
    params.require(:block).permit(
      identity_ids: [],
      paragraphs_attributes: [:id, :content],
      block_images_attributes: [:id, :image]
    )
  end

end
