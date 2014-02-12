class Block < ActiveRecord::Base
  include Uuidable

  
  IdentitiesClasses           = [Paragraph, BlockImage, Vacancy]
  DestroyableIdentityClasses  = [Paragraph, BlockImage]


  TYPES = IdentitiesClasses.map {|i| i.to_s.underscore }.inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }
  

  belongs_to :owner, polymorphic: true


  has_many :block_identities, -> { includes(:identity).order(:position) }, dependent: :destroy
  

  before_save :ensure_position
  
  
  def self.should_destroy_identity?(identity)
    DestroyableIdentityClasses.include?(identity.class)
  end
  
  
  def identity_class
    @identity_class ||= ActiveSupport.const_get(identity_type)
  end


  protected
  

  def ensure_position
    self.position = owner.blocks_by_section(section).length
  end


end
