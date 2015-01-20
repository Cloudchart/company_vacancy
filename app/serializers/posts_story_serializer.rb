class PostsStorySerializer < ActiveModel::Serializer

  attributes :uuid, :post_id, :story_id, :position, :is_important

end
