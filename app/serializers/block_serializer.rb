class BlockSerializer < ActiveModel::Serializer
  attributes :uuid, :position, :owner_id, :owner_type, :identity_type, :is_locked
  attributes :identity_ids, :kind
  
end
