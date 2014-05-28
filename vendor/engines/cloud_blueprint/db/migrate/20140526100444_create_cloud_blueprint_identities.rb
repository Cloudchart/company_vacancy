class CreateCloudBlueprintIdentities < ActiveRecord::Migration
  def up
    create_table :cloud_blueprint_identities, id: false do |t|
      t.string  :uuid,        limit: 36,  null: false
      t.string  :chart_id,    limit: 36,  null: false
      t.string  :node_id,     limit: 36,  null: false
      t.string  :identity_id, limit: 36,  null: false
      t.string  :identity_type,           null: false
      t.boolean :is_primary,              default: false
      t.timestamps
    end

    execute 'ALTER TABLE cloud_blueprint_identities ADD PRIMARY KEY (uuid);'
  end
  
  def down
    drop_table :cloud_blueprint_identities
  end
end
