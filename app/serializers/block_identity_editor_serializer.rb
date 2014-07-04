class BlockIdentityEditorSerializer < ActiveModel::Serializer


  attributes :uuid


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


end
