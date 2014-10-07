class CreatePictures < ActiveRecord::Migration
  def up
    create_table :pictures, id: false do |t|
      t.string  :uuid,        limit: 36
      t.string  :owner_id,    limit: 36
      t.string  :owner_type
      t.string  :image_uid
      t.timestamps
    end

    add_index :pictures, [:owner_id, :owner_type]
    execute 'ALTER TABLE pictures ADD PRIMARY KEY (uuid);'
  end
  
  def down
    drop_table :pictures
  end
end
