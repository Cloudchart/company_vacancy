class Block < ActiveRecord::Base
  include Uuidable

  
  IdentitiesClasses           = [Paragraph, BlockImage, Vacancy]


  TYPES = IdentitiesClasses.map {|i| i.to_s.underscore }.inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }
  

  belongs_to :owner, polymorphic: true


  has_many :block_identities, -> { includes(:identity).order(:position) }, dependent: :destroy
  

  before_create :ensure_position
  before_destroy :destroy_identities
  after_destroy :reposition_siblings
  
  
  def self.identities_to_destroy_with_block
    [Paragraph, BlockImage]
  end
  
  
  def identity_class
    @identity_class ||= ActiveSupport.const_get(identity_type)
  end


  protected
  

  def ensure_position
    self.position = owner.blocks_by_section(section).length
  end
  
  
  def destroy_identities
    block_identities.map(&:identity).each do |identity|
      identity.destroy if identity.should_be_destroyed_with_block?
    end
  end
  

  def reposition_siblings
    Block.transaction do
      owner.blocks_by_section(section).each_with_index do |sibling, index|
        sibling.update_attribute :position, index
      end
    end
  end


end
