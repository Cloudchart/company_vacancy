class Block < ActiveRecord::Base
  include Uuidable

  
  IdentitiesClasses           = [Paragraph, BlockImage, Vacancy]


  TYPES = IdentitiesClasses.map {|i| i.to_s.underscore }.inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }
  

  belongs_to :owner, polymorphic: true


  has_many :block_identities, -> { order(:position) }, inverse_of: :block
  

  IdentitiesClasses.each do |identity_class|
    plural_identity_name = identity_class.name.underscore.pluralize

    has_many :"#{plural_identity_name}", through: :block_identities, source: :identity, source_type: identity_class
    
    define_method :"#{plural_identity_name}_with_identities_load" do
      public_send(:"#{plural_identity_name}_without_identities_load").tap do |reflection|
        reflection.instance_variable_get(:"@association").target = block_identities.map(&:identity) if block_identities.loaded? unless reflection.loaded?
      end
    end
    
    alias_method_chain :"#{plural_identity_name}", :identities_load
        
    accepts_nested_attributes_for :"#{identity_class.name.underscore.pluralize}"
  end
    

  before_create   :ensure_position
  before_destroy  :destroy_identities
  after_destroy   :reposition_siblings
  
  
  def self.identities_to_destroy_with_block
    [Paragraph, BlockImage]
  end
  
  
  def identity_class
    @identity_class ||= ActiveSupport.const_get(identity_type.classify)
  end
  
  def identity_name
    @singular_identity_name ||= identity_class.name.underscore
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
    public_send :"#{singular_identity_name}_ids"
  end
  
  def identity_ids=(*args)
    public_send :"#{singular_identiy_name}_ids=", *args
  end
  
  
protected
  

  def ensure_position
    self.position = owner.blocks_by_section(section).length
  end
  
  
  def reposition_siblings
    Block.transaction do
      owner.blocks_by_section(section).each_with_index do |sibling, index|
        sibling.update_attribute :position, index
      end
    end
  end
  
  
  def destroy_identities
    block_identities.each(&:skip_reposition!).each(&:destroy!)
  end
  

end
