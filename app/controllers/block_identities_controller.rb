class BlockIdentitiesController < ApplicationController


  # Index
  #
  def index
    block_identities = Block.find(params[:block_id]).block_identities.includes(:identity).all

    respond_to do |format|
      format.json { render json: block_identities, root: false }
    end
  end
  
  
  # Create
  #
  def create
    block_identity = Block.find(params[:block_id]).block_identities.create!(params_for_create)
    
    respond_to do |format|
      format.json { render json: block_identity, root: false }
    end
  end
  
  
  # Update
  #
  def update
    block_identity = BlockIdentity.find(params[:id])
    block_identity.update!(params_for_update)

    respond_to do |format|
      format.json { render json: block_identity, root: false }
    end
  end


  # Destroy block identity
  #
  def destroy
    block_identity  = BlockIdentity.find(params[:id])
    block_identity.destroy
    
    respond_to do |format|
      format.json do
        render json: block_identity, root: false
      end
    end
  end


private


  def params_for_create
    params.require(:block_identity).permit([:uuid, :identity_id, :identity_type, :position])
  end
  

  def params_for_update
    params.require(:block_identity).permit([:identity_id, :position])
  end
  

end
