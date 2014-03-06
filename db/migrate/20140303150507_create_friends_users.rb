class CreateFriendsUsers < ActiveRecord::Migration
  def change
    create_table :friends_users, id: false do |t|
      t.string :friend_id, limit: 36
      t.string :user_id, limit: 36
    end
  end
end
