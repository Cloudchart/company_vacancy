class PostSerializer < ActiveModel::Serializer

  attributes  :uuid, :title, :published_at, :owner_id, :owner_type
  # attributes  :cover_url

end
