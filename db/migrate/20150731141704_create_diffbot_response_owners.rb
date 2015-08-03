class CreateDiffbotResponseOwners < ActiveRecord::Migration
  def up
    create_table :diffbot_response_owners, id: false do |t|
      t.string :uuid, limit: 36
      t.string :diffbot_response_id, limit: 36, null: false
      t.string :owner_id, limit: 36, null: false
      t.string :owner_type, null: false
      t.string :attribute_name, null: false

      t.timestamps
    end

    add_index :diffbot_response_owners, :diffbot_response_id
    add_index :diffbot_response_owners, [:owner_id, :owner_type]
    add_index :diffbot_response_owners, [:diffbot_response_id, :owner_id, :owner_type, :attribute_name], name: :diffbot_response_owners_idx, unique: true
    execute 'ALTER TABLE diffbot_response_owners ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :diffbot_response_owners, :diffbot_response_id
    remove_index :diffbot_response_owners, [:owner_id, :owner_type]
    remove_index :diffbot_response_owners, name: :diffbot_response_owners_idx
    drop_table :diffbot_response_owners
  end
end
