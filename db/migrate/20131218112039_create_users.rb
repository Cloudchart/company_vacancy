class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :phone

      t.timestamps
    end

    execute 'ALTER TABLE users ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :users
  end
end
