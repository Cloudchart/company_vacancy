class CreateFavorites < ActiveRecord::Migration
  def up
    create_table :favorites, id: false do |t|
      t.string :uuid, limit: 36
      t.string :user_id, limit: 36, null: false
      t.string :favoritable_id, limit: 36, null: false
      t.string :favoritable_type, null: false

      t.timestamps
    end

    add_index :favorites, :user_id
    add_index :favorites, [:favoritable_id, :favoritable_type]
    execute 'ALTER TABLE favorites ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :favorites, :user_id
    remove_index :favorites, [:favoritable_id, :favoritable_type]
    drop_table :favorites
  end
end
