class CreateFriendsUsers < ActiveRecord::Migration
  def change
    create_table :friends_users, id: false do |t|
      t.string :friend_id, limit: 36, null: false
      t.string :user_id, limit: 36, null: false
    end

    add_index :friends_users, [:friend_id, :user_id], unique: true
  end
end
