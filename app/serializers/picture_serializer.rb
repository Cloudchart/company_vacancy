class PictureSerializer < ActiveModel::Serializer
  attributes  :uuid, :owner_id, :owner_type
  attributes  :url, :size_
  attributes  :created_at, :updated_at

  def url
    object.image.thumb('1600x>').url if object.image_stored?
  end

  def size_
    object.size
  end
end
