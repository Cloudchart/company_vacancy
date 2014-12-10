class CreateVisibilities < ActiveRecord::Migration
  def up
    create_table :visibilities, id: false do |t|
      t.string :uuid, limit: 36
      t.string :value, null: false
      t.string :attribute_name
      t.string :owner_id, limit: 36, null: false
      t.string :owner_type, null: false

      t.timestamps
    end

    add_index :visibilities, [:owner_id, :owner_type]
    execute 'ALTER TABLE visibilities ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :visibilities, [:owner_id, :owner_type]
    drop_table :visibilities
  end
end
