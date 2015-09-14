class CreateNotifications < ActiveRecord::Migration
  def up
    create_table :notifications, id: false do |t|
      t.string :uuid, limit: 36
      t.string :user_id, limit: 36

      t.timestamps
    end

    add_index :notifications, :user_id
    execute 'ALTER TABLE notifications ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :notifications
  end
end
