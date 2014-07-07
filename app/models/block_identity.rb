class BlockIdentity < ActiveRecord::Base
  include Uuidable

  before_create   :ensure_position
  before_destroy  :destroy_identity, :reload_position
  after_destroy   :reposition_siblings
  
  belongs_to :block, inverse_of: :block_identities
  belongs_to :identity, polymorphic: true, inverse_of: :block_identity
  # has_paper_trail
  

  def self.accessible_attributes
    [:block_id, :identity_id, :identity_type]
  end
  
  def skip_reposition!
    @should_skip_reposition = true
  end

  def should_skip_reposition?
    !!@should_skip_reposition
  end
  
protected

  def ensure_position
    self.position = block.block_identities.size unless self.position.present?
  end
  
  def destroy_identity
    identity.destroy if Block.identities_to_destroy_with_block.include?(identity.class)
  end
  
  def reposition_siblings
    return if should_skip_reposition?

    BlockIdentity.transaction do
      BlockIdentity.where(block_id: block.to_param).where('position > ?', position).update_all('position = (position - 1)')
    end
  end
  
  def reload_position
    return if should_skip_reposition?

    reload
  end

end
