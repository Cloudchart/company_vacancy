class Block < ActiveRecord::Base
  include Extensions::UUID

  TITLES = %i(about product people vacancies contacts).inject({}) { |hash, val| hash.merge({ I18n.t("models.block.titles.#{val}") => val }) }

  belongs_to :owner, polymorphic: true
  belongs_to :blockable, polymorphic: true
end
