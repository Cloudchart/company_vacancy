class CreateBlockItems < ActiveRecord::Migration
  def up
    create_table :block_items, id: false do |t|
      t.string :uuid, limit: 36
      t.string :title, null: false
      t.integer :position
      t.string :ownerable_id, limit: 36, null: false
      t.string :ownerable_type, null: false
      t.string :itemable_id, limit: 36, null: false
      t.string :itemable_type, null: false

      t.timestamps
    end

    add_index :block_items, [:ownerable_id, :ownerable_type]
    add_index :block_items, [:itemable_id, :itemable_type]
    execute "ALTER TABLE block_items ADD PRIMARY KEY (uuid);"
  end

  def down
    drop_table :block_items
  end
end
