class BlockIdentitySerializer < ActiveModel::Serializer

  attributes :uuid, :block_id, :identity_id, :identity_type, :identity, :position, :created_at, :updated_at
  
end
