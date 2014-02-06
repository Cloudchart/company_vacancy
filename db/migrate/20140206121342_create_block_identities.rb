class CreateBlockIdentities < ActiveRecord::Migration
  def up
    create_table :block_identities, id: false do |t|
      t.string      :uuid,          limit: 36
      t.string      :block_id,      limit: 36
      t.string      :identity_id,   limit: 36
      t.string      :identity_type
      t.integer     :position,      default: 0
      t.timestamps
    end

    add_index :block_identities, :block_id
    add_index :block_identities, [:identity_id, :identity_type]
    execute 'ALTER TABLE block_identities ADD PRIMARY KEY (uuid);'
  end
  
  def down
    drop_table :block_identities
  end
end
