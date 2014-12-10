class VisibilitySerializer < ActiveModel::Serializer

  attributes :uuid, :value, :attribute_name, :owner_id, :owner_type
  attributes :created_at, :updated_at

end
