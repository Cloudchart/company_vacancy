class BlockImage < Image
  include Blockable
  include Imageable

  validates :image, presence: true

end
