class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions, id: false do |t|
      t.string :user_id, limit: 36, null: false
      t.string :subscribable_id, limit: 36, null: false
      t.string :subscribable_type, null: false
      t.string :subscription_type
      t.datetime :created_at
    end

    add_index :subscriptions, :user_id
    add_index :subscriptions, [:subscribable_id, :subscribable_type]
    add_index :subscriptions, :subscription_type
  end
end
