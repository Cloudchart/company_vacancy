class CreateTaggings < ActiveRecord::Migration
  def up
    create_table :taggings, id: false do |t|
      t.string :uuid, limit: 36
      t.string :tag_id, limit: 36, null: false
      t.string :taggable_id, limit: 36, null: false
      t.string :taggable_type, null: false
      t.string :tagger_id, limit: 36
      t.string :tagger_type
      t.datetime :created_at
    end

    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type]
    add_index :taggings, [:tagger_id, :tagger_type]
    add_index :taggings, [:tag_id, :taggable_id, :taggable_type, :tagger_id, :tagger_type], name: :taggings_idx, unique: true
    execute 'ALTER TABLE taggings ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :taggings, :tag_id
    remove_index :taggings, [:taggable_id, :taggable_type]
    remove_index :taggings, [:tagger_id, :tagger_type]
    remove_index :taggings, name: :taggings_idx
    drop_table :taggings
  end
end
