class DropFriends < ActiveRecord::Migration
  def up
    drop_table :friends
  end

  def down
    create_table :friends, id: false do |t|
      t.string :uuid, limit: 36
      t.string :provider, null: false
      t.string :external_id, null: false
      t.string :full_name, null: false

      t.timestamps
    end

    execute 'ALTER TABLE friends ADD PRIMARY KEY (uuid);'
  end
end
