class CreatePins < ActiveRecord::Migration
  def up
    create_table :pins, id: false do |t|
      t.string  :uuid,          limit: 36
      t.string  :user_id,       limit: 36, null: false
      t.string  :parent_id,     limit: 36
      t.string  :pinboard_id,   limit: 36
      t.string  :pinnable_id,   limit: 36
      t.string  :pinnable_type
      t.text    :content

      t.timestamps
    end
    
    add_index :pins, :user_id
    add_index :pins, :parent_id
    add_index :pins, :pinboard_id
    add_index :pins, [:pinnable_id, :pinnable_type]

    execute 'ALTER TABLE pins ADD PRIMARY KEY (uuid);'
  end
  

  def down
    remove_index :pins, :user_id
    remove_index :pins, :parent_id
    remove_index :pins, :pinboard_id
    remove_index :pins, [:pinnable_id, :pinnable_type]

    drop_table :pins
  end
end
