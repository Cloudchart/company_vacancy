class CreateLandings < ActiveRecord::Migration
  def up
    create_table :landings, id: false do |t|
      t.string :uuid, limit: 36
      t.string :title
      t.string :image_uid
      t.text :body
      t.string :slug
      t.string :user_id, limit: 36

      t.timestamps
    end

    add_index :landings, :user_id
    execute 'ALTER TABLE landings ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :landings, :user_id
    drop_table :landings
  end
end
