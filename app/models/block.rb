class Block < ActiveRecord::Base
  include Uuidable

  KINDS = %i(about product people vacancies contacts).inject({}) { |hash, val| hash.merge({ I18n.t("block.kinds.#{val}") => val }) }
  
  belongs_to :owner, polymorphic: true
  belongs_to :blockable, polymorphic: true

  validates :position, presence: true

end
