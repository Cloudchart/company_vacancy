class Block < ActiveRecord::Base
  include Uuidable

  TYPES = %i(text image chart person widget).inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }
  
  belongs_to :owner, polymorphic: true

  has_many :block_identities, -> { includes(:identity).order(:position) }, dependent: :destroy
  

  def identities
    block_identities.map(&:identity) || []
  end
  

  def identity
    identities.first
  end


  before_save :ensure_position


  def type
    @type ||= blockable_type.to_s.downcase.to_sym
  end


  protected
  
  def ensure_position
    self.position = owner.blocks_by_section(section).length
  end

end
