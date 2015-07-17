class AddWeightToPin < ActiveRecord::Migration
  def change
    add_column :pins, :weight, :integer
  end
end
