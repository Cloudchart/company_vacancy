class BlockIdentitiesController < ApplicationController
  
  def create
    @block_identity = BlockIdentity.new params.require(:block_identity).permit(*BlockIdentity.accessible_attributes)

    identity_params = params_for_identity(@block_identity)
    @identity = identity_class(@block_identity).new identity_params.permit!

    @identity.save!
    @block_identity.identity = @identity
    @block_identity.save!
  rescue ActionController::ParameterMissing
  rescue ActiveRecord::RecordInvalid
  ensure
    redirect_to @block_identity.block.owner
  end
  
  
  def update
    @block_identity = BlockIdentity.find params[:id]
    @block_identity.identity.update_attributes! params_for_identity(@block_identity).permit!
  rescue ActiveRecord::RecordInvalid
    @block_identity.destroy
  ensure
    redirect_to @block_identity.block.owner
  end
  
  
  def destroy
    block_identity = BlockIdentity.includes(block: :owner).find(params[:id])
    block_identity.destroy

    redirect_to block_identity.block.owner
  end


protected

  
  def identity_class(block_identity)
    ActiveSupport.const_get(block_identity.identity_type)
  end


  def params_for_identity(block_identity)
    params.require(:block_identity).require(block_identity.identity_type.underscore.to_sym)
  end
  
end
