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
      content:  object.content
    }
  end
  
  
  def block_image_attributes
    {
      image:    object.image.url,
      meta:     object.meta.marshal_dump
    }
  end
  
  
  def person_attributes
    data = {
      first_name:   object.first_name,
      last_name:    object.last_name,
      occupation:   object.occupation
    }
    
    data.merge!({ avatar_url: object.user.avatar.url }) if object.user and object.user.avatar_stored?
    
    data
  end


  def vacancy_attributes
    {
      name:         object.name,
      description:  object.description
    }
  end


end
