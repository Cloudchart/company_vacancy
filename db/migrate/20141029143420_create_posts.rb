class CreatePosts < ActiveRecord::Migration
  def up
    create_table :posts, id: false do |t|
      t.string :uuid, limit: 36
      t.string :title
      t.datetime :published_at
      t.boolean :is_published, default: false
      t.string :owner_id, limit: 36
      t.string :owner_type

      t.timestamps
    end

    add_index :posts, [:owner_id, :owner_type]
    execute 'ALTER TABLE posts ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :posts, [:owner_id, :owner_type]
    drop_table :posts
  end
end
