class BlockEditorSerializer < ActiveModel::Serializer
  attributes :uuid, :position, :identity_type, :block_type, :is_locked, :url

  has_many :identities, serializer: BlockIdentityEditorSerializer
  
  def block_type
    object.identity_type.underscore
  end
  
  def url
    block_path(object)
  end
end
