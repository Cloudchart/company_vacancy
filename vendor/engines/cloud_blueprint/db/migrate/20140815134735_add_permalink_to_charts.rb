class AddPermalinkToCharts < ActiveRecord::Migration
  def change
    add_column :cloud_blueprint_charts, :permalink, :string
  end
end
