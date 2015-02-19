class PostsStory < ActiveRecord::Base
  include Uuidable

  belongs_to :story, counter_cache: true
  belongs_to :post

  def company
    post.company
  end
  
end
