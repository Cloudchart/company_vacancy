class AddSizeToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :size, :integer, default: 0
  end
end
