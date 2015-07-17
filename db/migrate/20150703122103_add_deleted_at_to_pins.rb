class AddDeletedAtToPins < ActiveRecord::Migration
  def change
    add_column :pins, :deleted_at, :datetime
    add_index :pins, :deleted_at
  end
end
