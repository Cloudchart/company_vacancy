class BlockIdentitiesController < ApplicationController


  # Destroy block identity
  #
  def destroy
    block_identity  = BlockIdentity.find(params[:id])
    block_identity.destroy
    
    respond_to do |format|
      format.json do
        render json: nil
      end
    end
  end
  
  
end
