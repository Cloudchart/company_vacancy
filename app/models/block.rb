class Block < ActiveRecord::Base
  include Uuidable

  TYPES = %i(text image chart person widget).inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }
  
  belongs_to :owner, polymorphic: true

  has_many :block_identities, -> { includes(:identity).order(:position) }, dependent: :destroy

  before_save :ensure_position
  
  
  def identities
    block_identities.map(&:identity)
  end
  
  
  def identity
    identities.first
  end
  
  
  def identity_type
    @identity_type ||= blockable_type.underscore
  end
  
  def identity_class
    @identity_class ||= ActiveSupport.const_get(identity_type.classify)
  end
  
  
  def type
    @type ||= blockable_type.to_s.downcase.to_sym
  end


  protected
  
  def ensure_position
    self.position = owner.blocks_by_section(section).length
  end

end
