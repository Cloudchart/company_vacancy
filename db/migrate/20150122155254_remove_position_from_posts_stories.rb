class RemovePositionFromPostsStories < ActiveRecord::Migration
  def change
    remove_column :posts_stories, :position, :integer, default: 0
  end
end
