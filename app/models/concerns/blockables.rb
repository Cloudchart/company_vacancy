module Blockables
  extend ActiveSupport::Concern

  included do
    has_many :block_identities, as: :identity, dependent: :destroy
    has_many :blocks, through: :block_identities
  
    Block.class_eval <<-END
    
      def #{self.name.underscore.pluralize}=(instances)
        instances.each { |instance| instance.blocks << self }
      end
    
    END
  
    def block_ids=(ids)
      blocks = Block.find(ids) rescue []
      self.blocks = blocks
    end
    
    def should_be_destroyed_with_block?
      Block.identities_to_destroy_with_block.includes?(self.class)
    end

  end

end
