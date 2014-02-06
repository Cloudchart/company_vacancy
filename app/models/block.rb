class Block < ActiveRecord::Base
  include Uuidable

  TYPES = %i(text image chart person widget).inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }
  
  belongs_to :owner, polymorphic: true
  belongs_to :blockable, polymorphic: true

  #validates :position, presence: true
  
  before_save :ensure_position
  

  def type
    @type ||= blockable_type.to_s.downcase.to_sym
  end


  protected
  
  def ensure_position
    self.position = owner.blocks_by_section(section).length
  end

end
