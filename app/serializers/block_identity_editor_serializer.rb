class BlockIdentityEditorSerializer < ActiveModel::Serializer


  attributes :uuid, :url


  def url
    identity_path(object.block_identity)
  end


  def attributes
    data = super
    data.merge! public_send(:"#{object.class.name.underscore}_attributes")
    data
  end
  

  def paragraph_attributes
    {
      content: object.content
    }
  end
  
  
  def block_image_attributes
    {
      uuid:     object.uuid,
      image:    object.image.url,
      meta:     object.meta.marshal_dump
    }
  end


end
