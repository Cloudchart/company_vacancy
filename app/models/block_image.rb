class BlockImage < Image
  include Uuidable
  include Blockable
  include Imageable

  validates :image, presence: true

end
