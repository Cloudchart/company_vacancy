module Blockable
  extend ActiveSupport::Concern

  included do
    has_one :block_identity, as: :identity, dependent: :destroy
    has_one :block, through: :block_identity
  
  
    def block_id=(id)
      block = Block.find(id)
      self.block = block
    end
    
    def should_be_destroyed_with_block?
      Block.identities_to_destroy_with_block.includes?(self.class)
    end

  end

end
