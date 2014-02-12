class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :avatar_id, limit: 36
      t.string :phone

      t.timestamps
    end

    add_index :users, :avatar_id
    execute 'ALTER TABLE users ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :users
  end
end
