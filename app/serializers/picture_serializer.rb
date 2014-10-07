class PictureSerializer < ActiveModel::Serializer
  attributes  :uuid, :owner_id, :owner_type
  attributes  :url
  attributes  :created_at, :updated_at
  
  def url
    object.image.url if object.image_stored?
  end
end
