class AddFieldsToFriendsUsers < ActiveRecord::Migration
  def up
    add_column :friends_users, :uuid, :string, limit: 36
    add_column :friends_users, :data, :text
    add_column :friends_users, :created_at, :datetime
    add_column :friends_users, :updated_at, :datetime
    add_index :friends_users, :friend_id
    add_index :friends_users, :user_id
    execute 'ALTER TABLE friends_users ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_column :friends_users, :uuid
    remove_column :friends_users, :data
    remove_column :friends_users, :created_at
    remove_column :friends_users, :updated_at
    remove_index :friends_users, :friend_id
    remove_index :friends_users, :user_id
  end
end
