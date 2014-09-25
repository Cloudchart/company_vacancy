class CreateTags < ActiveRecord::Migration
  def up
    create_table :tags, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name
      t.integer :taggings_count, default: 0
      t.boolean :is_acceptable, default: false
      
      t.timestamps
    end

    add_index :tags, :name, unique: true
    execute 'ALTER TABLE tags ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :tags, :name
    drop_table :tags
  end
end
