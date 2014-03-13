class CreateVotes < ActiveRecord::Migration
  def up
    create_table :votes, id: false do |t|
      t.string :uuid, limit: 36
      t.string :source_id, limit: 36, null: false
      t.string :source_type, null: false
      t.string :destination_id, limit: 36, null: false
      t.string :destination_type, null: false
      t.integer :value, default: 1, null: false

      t.timestamps
    end

    add_index :votes, [:source_id, :source_type]
    add_index :votes, [:destination_id, :destination_type]
    add_index :votes, [:source_id, :destination_id], unique: true
    execute 'ALTER TABLE votes ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :votes, [:source_id, :source_type]
    remove_index :votes, [:destination_id, :destination_type]
    remove_index :votes, [:source_id, :destination_id], unique: true
    drop_table :votes
  end
end
