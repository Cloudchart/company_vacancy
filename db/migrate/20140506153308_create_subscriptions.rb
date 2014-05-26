class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions, id: false do |t|
      t.string :user_id, limit: 36, null: false
      t.string :subscribable_id, limit: 36, null: false
      t.string :subscribable_type, null: false
      t.integer :types_mask
      t.datetime :created_at
    end

    add_index :subscriptions, :user_id
    add_index :subscriptions, [:subscribable_id, :subscribable_type]
  end
end
