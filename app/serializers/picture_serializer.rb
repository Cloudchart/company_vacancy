class PictureSerializer < ActiveModel::Serializer
  attributes  :uuid
  attributes  :url
  attributes  :created_at, :updated_at
  
  def url
    object.image.url if object.image_stored?
  end
end
