class VisibilitySerializer < ActiveModel::Serializer

  attributes :uuid, :value, :event_name, :owner_id, :owner_type
  attributes :created_at, :updated_at

end
