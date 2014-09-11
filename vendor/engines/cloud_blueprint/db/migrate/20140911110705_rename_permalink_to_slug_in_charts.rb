class RenamePermalinkToSlugInCharts < ActiveRecord::Migration
  def change
    rename_column :cloud_blueprint_charts, :permalink, :slug
  end
end
