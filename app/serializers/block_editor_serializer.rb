class BlockEditorSerializer < ActiveModel::Serializer
  attributes :uuid, :section, :position, :identity_type, :is_locked, :url

  has_many :identities, serializer: BlockIdentityEditorSerializer
  
  def url
    block_path(object)
  end
end
