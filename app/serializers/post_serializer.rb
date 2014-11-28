class PostSerializer < ActiveModel::Serializer

  attributes :uuid, :title, :published_at, :is_published, :owner_id, :owner_type, :tag_names

end
