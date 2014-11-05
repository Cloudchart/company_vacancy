class Block < ActiveRecord::Base
  include Uuidable
  include Trackable
  
  IdentitiesClasses = [Picture, Paragraph, Person, Vacancy, Company]
  
  before_create   :shift_siblings_down
  after_destroy   :shift_siblings_up

  belongs_to :owner, polymorphic: true

  has_one :picture, as: :owner, dependent: :destroy
  has_one :paragraph, as: :owner, dependent: :destroy

  has_many :block_identities, -> { order(:position) }, inverse_of: :block, dependent: :destroy  
  
  IdentitiesClasses.each do |identity_class|
    plural_identity_name = identity_class.name.underscore.pluralize

    has_many :"#{plural_identity_name}", through: :block_identities, source: :identity, source_type: identity_class
    
    define_method :"#{plural_identity_name}_with_identities_load" do
      public_send(:"#{plural_identity_name}_without_identities_load").tap do |proxy|
        proxy.instance_variable_get(:"@association").target = block_identities.map(&:identity) if block_identities.loaded? unless proxy.loaded?
      end
    end
    
    alias_method_chain :"#{plural_identity_name}", :identities_load
        
    accepts_nested_attributes_for :"#{identity_class.name.underscore.pluralize}"
  end
  
  def self.identities_to_destroy_with_block
    []
  end

  def company
    if owner_type == 'Company'
      owner
    elsif owner_type =~ /Event|Vacancy|Post/
      owner.company
    end
  end
  
  def identity_class
    @identity_class ||= ActiveSupport.const_get(identity_type.classify)
  end
  
  def identity_name
    @identity_name ||= identity_class.name.underscore
  end

  alias_method :singular_identity_name, :identity_name

  def plural_identity_name
    @plural_identity_name ||= singular_identity_name.pluralize
  end

  def identities
    public_send :"#{plural_identity_name}"
  end
  
  def identities=(*args, &block)
    public_send :"#{plural_identity_name}=", *args, &block
  end
  
  def identity_ids
    block_identities.map(&:identity_id)
  end
  

  def identity_ids=(args)
    ids = args.reject(&:blank?)

    public_send :"#{singular_identity_name}_ids=", ids

    block_identities.each do |block_identity|
      block_identity.update_attribute :position, ids.index(block_identity.identity_id)
    end
  end
  

  def clear_identity_ids=(status)
    self.identity_ids = [] if status
  end


private

  def shift_siblings_down
    Block.transaction do
      owner.blocks.where('position >= ?', position).each_with_index do |block, index|
        block.update_attribute(:position, position + index + 1)
      end
    end
  end

  def shift_siblings_up
    Block.transaction do
      owner.blocks.where('position >= ?', position).each_with_index do |block, index|
        block.update_attribute(:position, position + index)
      end
    end
  end
  
end
