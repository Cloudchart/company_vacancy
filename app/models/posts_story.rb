class PostsStory < ActiveRecord::Base

  belongs_to :story, counter_cache: true
  belongs_to :post
  
end
