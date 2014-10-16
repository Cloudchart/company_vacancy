class FavoriteSerializer < ActiveModel::Serializer
  attributes :uuid, :favoritable_id
end
