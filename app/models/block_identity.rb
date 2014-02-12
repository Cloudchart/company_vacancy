class BlockIdentity < ActiveRecord::Base

  include Uuidable  
  
  belongs_to :block
  
  belongs_to :identity, polymorphic: true
  
  before_create   :ensure_position
  before_destroy  :destroy_identity
  after_destroy   :reposition_siblings  
  
  
  def self.accessible_attributes
    [:block_id, :identity_id, :identity_type]
  end
  
  
protected

  def ensure_position
    self.position = block.block_identities.size
  end
  
  def destroy_identity
    identity.destroy if Block.should_destroy_identity?(identity)
  end
  
  def reposition_siblings
    BlockIdentity.transaction do
      block.block_identities.each_with_index do |sibling, index|
        sibling.update_attribute position: index
      end
    end
  end
  
end
