class AddStockOptionsToPerson < ActiveRecord::Migration
  def change
    add_column :people, :stock_options, :float
  end
end
