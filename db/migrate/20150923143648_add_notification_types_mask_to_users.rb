class AddNotificationTypesMaskToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notification_types_mask, :integer, default: 0
  end
end
