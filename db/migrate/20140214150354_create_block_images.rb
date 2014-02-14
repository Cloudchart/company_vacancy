class CreateBlockImages < ActiveRecord::Migration
  def up
    create_table :block_images, id: false do |t|
      t.string :uuid, limit: 36
      t.string :image, null: false
      t.text :meta

      t.timestamps
    end

    execute 'ALTER TABLE block_images ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :block_images
  end
end
