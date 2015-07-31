class CreateDiffbotResponseOwners < ActiveRecord::Migration
  def up
    create_table :diffbot_response_owners, id: false do |t|
      t.string :uuid, limit: 36
      t.string :diffbot_response_id, limit: 36, null: false
      t.string :owner_id, limit: 36, null: false
      t.string :owner_type, null: false
      t.string :attr

      t.timestamps
    end

    add_index :diffbot_response_owners, :diffbot_response_id
    add_index :diffbot_response_owners, [:owner_id, :owner_type]
    execute 'ALTER TABLE diffbot_response_owners ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :diffbot_response_owners, :diffbot_response_id
    remove_index :diffbot_response_owners, [:owner_id, :owner_type]
    drop_table :diffbot_response_owners
  end
end
