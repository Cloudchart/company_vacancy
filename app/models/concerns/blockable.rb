module Blockable
  extend ActiveSupport::Concern

  included do
    has_one :block_identity, as: :identity
    has_one :block, through: :block_identity
  

    after_destroy :destroy_identity
  

    def block_id=(id)
      block = Block.find(id)
      self.block = block
    end

  protected

    def destroy_identity
      if block.present?
        block_identity.destroy
      end
    end
  end

end
