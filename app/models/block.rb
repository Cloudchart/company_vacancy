class Block < ActiveRecord::Base
  include Uuidable

  TYPES = %i(text image chart person widget).inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }
  
  belongs_to :owner, polymorphic: true
  belongs_to :blockable, polymorphic: true

  validates :position, presence: true

end
