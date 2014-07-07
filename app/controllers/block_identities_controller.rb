class BlockIdentitiesController < ApplicationController

  
  # Create block identity
  #
  def create
    block     = Block.find(params[:block_id])
    identity  = block.identity_class.create! attributes_for_identity(block.identity_class.name)
    block.identities << identity
    
    respond_to do |format|
      format.json do
        render json: identity, serializer: BlockIdentityEditorSerializer, root: false
      end
    end
  end

  
  # Update block identity
  #
  def update
    block_identity  = BlockIdentity.includes(:identity).find(params[:id])
    identity        = block_identity.identity

    identity.update!        attributes_for_identity_update(identity)
    
    respond_to do |format|
      format.json do
        render json: identity, serializer: BlockIdentityEditorSerializer, root: false
      end
    end
  end
  
  
  # Destroy block identity
  #
  def destroy
    block_identity  = BlockIdentity.find(params[:id])
    block_identity.destroy
    
    respond_to do |format|
      format.json { render json: nil }
    end
  end
  
  
private


  def attributes_for_identity(identity)
    identity_name = if identity.is_a? String then identity else identity.class.name end
    params.require(:block_identity).require(:identity_attributes).permit(send(:"#{identity_name.underscore}_attributes"))
  end
  

  def paragraph_attributes
    [:content]
  end

  
end
