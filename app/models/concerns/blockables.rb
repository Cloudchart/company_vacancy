module Blockables
  extend ActiveSupport::Concern

  included do
    has_many :block_identities, as: :identity, dependent: :destroy
    has_many :blocks, through: :block_identities
  
    Block.class_eval <<-END
    
      def #{name.underscore.pluralize}=(instances)
        instances.each { |instance| instance.blocks << self }
      end
    
      def #{name.underscore.pluralize}_ids=(ids)
        #{name}.transaction do
          instances = #{name}.find(ids) rescue []
          instances.each { |instance| instance.blocks << self }
        end
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
