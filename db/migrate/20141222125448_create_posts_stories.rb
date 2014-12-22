class CreatePostsStories < ActiveRecord::Migration
  def change
    create_table :posts_stories, id: false do |t|
      t.string :post_id, limit: 36, null: false
      t.string :story_id, limit: 36, null: false
    end

    add_index :posts_stories, [:post_id, :story_id], unique: true
  end
end
