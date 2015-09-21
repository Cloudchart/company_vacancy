class CreateDeviceTokens < ActiveRecord::Migration
  def up
    create_table :device_tokens, id: false do |t|
      t.string :uuid, limit: 36
      t.string :user_id, limit: 36, null: false
      t.string :value, null: false

      t.timestamps
    end

    add_index :device_tokens, :user_id
    execute 'ALTER TABLE device_tokens ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :device_tokens, :user_id
    drop_table :device_tokens
  end
end
