class ChangeDisplayTypesMaskInFeatures < ActiveRecord::Migration
  def up
    change_column :features, :display_types_mask, :integer, default: 0
  end

  def down
    change_column :features, :display_types_mask, :integer, default: nil
  end
end
