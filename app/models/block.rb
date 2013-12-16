class Block < ActiveRecord::Base
  include Uuidable

  KINDS = %i(about product people vacancies contacts).inject({}) { |hash, val| hash.merge({ I18n.t("models.block.kinds.#{val}") => val }) }
  
  belongs_to :owner, polymorphic: true
  belongs_to :blockable, polymorphic: true

end
