module Blockable
  extend ActiveSupport::Concern

  included do
    has_one :block_identity, as: :identity, dependent: :destroy
    has_one :block, through: :block_identity
    
    def block_id=(id)
      block = Block.find(id) rescue nil
      self.block = block
    end
  end

end
