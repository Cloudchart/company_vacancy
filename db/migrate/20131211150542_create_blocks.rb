class CreateBlocks < ActiveRecord::Migration
  def up
    create_table :blocks, id: false do |t|
      t.string :uuid, limit: 36
      t.string :section, null: false
      t.integer :position, default: 0
      t.string :owner_id, limit: 36, null: false
      t.string :owner_type, null: false
      t.string :identity_type, null: false

      t.timestamps
    end

    add_index :blocks, [:owner_id, :owner_type]
    execute 'ALTER TABLE blocks ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :blocks
  end
end
