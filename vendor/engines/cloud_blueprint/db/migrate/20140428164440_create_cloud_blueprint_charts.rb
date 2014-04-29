class CreateCloudBlueprintCharts < ActiveRecord::Migration
  def up
    create_table :cloud_blueprint_charts, id: false do |t|
      t.string  :uuid,        limit: 36, null: false
      t.string  :company_id,  limit: 36, null: false
      t.string  :title
      t.timestamps
    end

    execute 'ALTER TABLE cloud_blueprint_charts ADD PRIMARY KEY (uuid);'
  end
  
  def down
    drop_table :cloud_blueprint_charts
  end
end
