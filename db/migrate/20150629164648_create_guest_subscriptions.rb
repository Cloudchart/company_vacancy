class CreateGuestSubscriptions < ActiveRecord::Migration
  def up
    create_table :guest_subscriptions, id: false do |t|
      t.string :uuid, limit: 36
      t.string :email
      t.boolean :is_verified, default: false

      t.timestamps
    end

    execute 'ALTER TABLE guest_subscriptions ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :guest_subscriptions
  end
end
