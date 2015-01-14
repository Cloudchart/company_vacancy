class PinboardSerializer < ActiveModel::Serializer

  attributes  :uuid, :title, :user_id, :position, :created_at, :updated_at

end
