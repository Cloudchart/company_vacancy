class UserSerializer < ActiveModel::Serializer
  attributes  :uuid
  attributes  :first_name, :last_name, :full_name
  attributes  :created_at, :updated_at
end
