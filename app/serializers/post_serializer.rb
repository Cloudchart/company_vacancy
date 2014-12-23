class PostSerializer < ActiveModel::Serializer

  attributes :uuid, :title, :published_at, :is_published, :owner_id, :owner_type, :story_ids
  attributes :created_at, :updated_at

  def published_at
    object.published_at.try(:to_date)
  end

end
