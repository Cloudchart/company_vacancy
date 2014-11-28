class PostSerializer < ActiveModel::Serializer

  attributes :uuid, :title, :published_at, :is_published, :owner_id, :owner_type, :tag_names
  attributes :created_at, :updated_at

end
