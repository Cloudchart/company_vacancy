class AddColorIndexToNode < ActiveRecord::Migration
  def change
    add_column :cloud_blueprint_nodes, :color_index, :integer, default: 0
  end
end
