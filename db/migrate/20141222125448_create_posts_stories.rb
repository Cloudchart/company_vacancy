class CreatePostsStories < ActiveRecord::Migration
  def up
    create_table :posts_stories, id: false do |t|
      t.string :uuid, limit: 36
      t.string :post_id, limit: 36, null: false
      t.string :story_id, limit: 36, null: false
      t.integer :position, default: 0
    end

    add_index :posts_stories, [:post_id, :story_id], unique: true
    execute 'ALTER TABLE posts_stories ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :posts_stories, [:post_id, :story_id]
    drop_table :posts_stories
  end
end
