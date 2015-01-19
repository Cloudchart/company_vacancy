class PinSerializer < ActiveModel::Serializer

  attributes  :uuid, :user_id, :parent_id, :pinboard_id
  attributes  :pinnable_id, :pinnable_type
  attributes  :content
  attributes  :created_at, :updated_at

end
