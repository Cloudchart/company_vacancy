class BlockSerializer < ActiveModel::Serializer

  attributes :uuid, :section, :position, :owner_id, :owner_type, :identity_type, :is_locked, :url

end