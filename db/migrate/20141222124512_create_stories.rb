class CreateStories < ActiveRecord::Migration
  def up
    create_table :stories, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name
      t.string :company_id, limit: 36
      t.integer :posts_stories_count, default: 0

      t.timestamps
    end

    add_index :stories, :company_id
    execute 'ALTER TABLE stories ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :stories, :company_id
    drop_table :stories
  end
end
