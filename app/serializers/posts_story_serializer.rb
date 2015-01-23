class PostsStorySerializer < ActiveModel::Serializer

  attributes :uuid, :post_id, :story_id, :is_highlighted

end
