class AddIsApprovedToPins < ActiveRecord::Migration
  def change
    add_column :pins, :is_approved, :boolean, default: false
  end
end
