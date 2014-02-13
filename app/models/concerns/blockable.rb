module Blockable
  extend ActiveSupport::Concern

  included do
    has_one :block_identity, as: :identity, dependent: :destroy
    has_one :block, through: :block_identity
  
    
    Block.class_eval <<-END
    
      def #{name.underscore}=(instance)
        instance.block = self
      end
    
      def #{name.underscore}_id=(id)
        instance = #{name}.find(id) rescue nil
        instance.block = self if instance.present?
      end
    
    END
  
  
    def block_id=(id)
      block = Block.find(id) rescue nil
      self.block = block
    end
    
    def should_be_destroyed_with_block?
      Block.identities_to_destroy_with_block.includes?(self.class)
    end

  end

end
