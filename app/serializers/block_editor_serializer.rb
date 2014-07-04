class BlockEditorSerializer < ActiveModel::Serializer
  attributes :uuid, :section, :position, :identity_type, :is_locked

  has_many :identities, serializer: BlockIdentityEditorSerializer
end
