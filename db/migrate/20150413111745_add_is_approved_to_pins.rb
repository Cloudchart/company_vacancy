class AddIsApprovedToPins < ActiveRecord::Migration
  def up
    add_column :pins, :is_approved, :boolean, default: false
    Pin.insights.update_all(is_approved: true)
  end

  def down
    remove_column :pins, :is_approved
  end
end
