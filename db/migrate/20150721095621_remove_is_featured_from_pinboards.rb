class RemoveIsFeaturedFromPinboards < ActiveRecord::Migration
  def change
    remove_column :pinboards, :is_featured, :boolean, default: false
  end
end
