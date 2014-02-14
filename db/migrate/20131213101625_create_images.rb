class CreateImages < ActiveRecord::Migration
  def up
    create_table :images, id: false do |t|
      t.string :uuid, limit: 36
      t.string :image, null: false
      t.string :owner_id, limit: 36, null: false
      t.string :owner_type, null: false
      t.text :meta
      t.string :type

      t.timestamps
    end

    add_index :images, [:owner_id, :owner_type]
    execute 'ALTER TABLE images ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :images
  end
end
