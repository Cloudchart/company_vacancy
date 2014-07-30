class AddIsPublicToCharts < ActiveRecord::Migration
  def change
    add_column :cloud_blueprint_charts, :is_public, :boolean, default: false
  end
end
