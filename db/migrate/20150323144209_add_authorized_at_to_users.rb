class AddAuthorizedAtToUsers < ActiveRecord::Migration
  def up
    add_column :users, :authorized_at, :datetime
    User.update_all(authorized_at: Time.now)
  end

  def down
    remove_column :users, :authorized_at
  end
end
