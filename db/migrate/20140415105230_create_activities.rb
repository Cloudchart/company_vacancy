class CreateActivities < ActiveRecord::Migration
  def up
    create_table :activities, id: false do |t|
      t.string :uuid, limit: 36
      t.string :action, null: false
      t.integer :group_type, default: 0
      t.string :user_id, limit: 36, null: false
      t.string :trackable_id, limit: 36
      t.string :trackable_type
      t.string :source_id, limit: 36
      t.string :source_type
      t.string :subscriber_id, limit: 36

      t.timestamps
    end

    add_index :activities, :user_id
    add_index :activities, [:source_id, :source_type]
    add_index :activities, [:trackable_id, :trackable_type]
    execute 'ALTER TABLE activities ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :activities, :user_id
    remove_index :activities, [:source_id, :source_type]
    remove_index :activities, [:trackable_id, :trackable_type]    
    drop_table :activities
  end
end
