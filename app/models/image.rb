class Image < ActiveRecord::Base
  include Uuidable
  include Blockable

  mount_uploader :image, ImageUploader

  validates :image, presence: true

end
