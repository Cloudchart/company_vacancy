class Text < ActiveRecord::Base
  has_one :block_item, as: :itemable
end
