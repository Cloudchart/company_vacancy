module Blockable
  extend ActiveSupport::Concern

  included do
    has_one :block, as: :blockable, dependent: :destroy
    has_one :company, through: :block, source: :owner, source_type: 'Company'
    accepts_nested_attributes_for :block
  end

end
