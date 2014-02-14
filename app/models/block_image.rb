class BlockImage < Image
  include Imageable

  validates :image, presence: true

end
