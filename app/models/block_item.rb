class BlockItem < ActiveRecord::Base
  include Extensions::UUID

  belongs_to :ownerable, polymorphic: true
  belongs_to :itemable, polymorphic: true, dependent: :destroy
end
