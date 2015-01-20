class AddIsImportantToPostsStories < ActiveRecord::Migration
  def change
    add_column :posts_stories, :is_important, :boolean, default: false
  end
end
