class AddIsHighlightedToPostsStories < ActiveRecord::Migration
  def change
    add_column :posts_stories, :is_highlighted, :boolean, default: false
  end
end
