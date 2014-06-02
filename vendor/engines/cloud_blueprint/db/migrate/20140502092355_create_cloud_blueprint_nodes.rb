class CreateCloudBlueprintNodes < ActiveRecord::Migration
  def up
    create_table :cloud_blueprint_nodes, id: false do |t|
      t.string  :uuid,        limit: 36, null: false
      t.string  :chart_id,    limit: 36, null: false
      t.string  :parent_id,   limit: 36
      t.string  :title
      t.integer :knots,       default: 0
      t.integer :position,    default: 0
      t.timestamps
    end

    execute 'ALTER TABLE cloud_blueprint_nodes ADD PRIMARY KEY (uuid);'
  end
  
  def down
    drop_table :cloud_blueprint_nodes
  end
end
