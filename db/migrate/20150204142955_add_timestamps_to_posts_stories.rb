class AddTimestampsToPostsStories < ActiveRecord::Migration
  def change
    add_column :posts_stories, :created_at, :datetime
    add_column :posts_stories, :updated_at, :datetime
  end
end
