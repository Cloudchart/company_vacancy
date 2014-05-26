class CreateSubscriptions < ActiveRecord::Migration
  def up
    create_table :subscriptions, id: false do |t|
      t.string :uuid, limit: 36
      t.string :user_id, limit: 36, null: false
      t.string :subscribable_id, limit: 36, null: false
      t.string :subscribable_type, null: false
      t.integer :types_mask
      t.datetime :created_at
    end

    add_index :subscriptions, :user_id
    add_index :subscriptions, [:subscribable_id, :subscribable_type]
    execute 'ALTER TABLE subscriptions ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :subscriptions, :user_id
    remove_index :subscriptions, [:subscribable_id, :subscribable_type]
    drop_table :subscriptions
  end
end
