class Text < ActiveRecord::Base
  include Extensions::UUID

  has_one :block, as: :blockable, dependent: :destroy
  has_one :company, through: :block, source: :owner, source_type: 'Company'

  accepts_nested_attributes_for :block
end
