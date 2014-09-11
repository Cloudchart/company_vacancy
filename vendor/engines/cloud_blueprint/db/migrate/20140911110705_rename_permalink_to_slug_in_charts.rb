class RenamePermalinkToSlugInCharts < ActiveRecord::Migration
  def up
    rename_column :cloud_blueprint_charts, :permalink, :slug
    add_index :cloud_blueprint_charts, :slug
  end

  def down
    rename_column :cloud_blueprint_charts, :slug, :permalink
  end
end
