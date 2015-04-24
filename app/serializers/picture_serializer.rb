class PictureSerializer < ActiveModel::Serializer
  attributes  :uuid, :owner_id, :owner_type
  attributes  :url, :size
  attributes  :created_at, :updated_at
  
  def url
    object.image.thumb('1600x>').url if object.image_stored?
  end
end
