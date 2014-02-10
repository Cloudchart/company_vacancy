class BlockImage < ActiveRecord::Base
  include Uuidable
  include Blockable
  include Imageable

  validates :image, presence: true

end
