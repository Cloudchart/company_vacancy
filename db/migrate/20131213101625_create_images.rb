class CreateImages < ActiveRecord::Migration
  def up
    create_table :images, id: false do |t|
      t.string :uuid, limit: 36
      t.string :image, null: false
      t.text :meta
      t.string :type

      t.timestamps
    end

    execute 'ALTER TABLE images ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :images
  end
end
