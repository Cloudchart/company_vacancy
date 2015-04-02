class ChangeIndexOnTwitterInUsers < ActiveRecord::Migration
  def change
    remove_index :users, column: :twitter
    add_index :users, :twitter, unique: true
  end
end
