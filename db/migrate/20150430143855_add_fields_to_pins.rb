class AddFieldsToPins < ActiveRecord::Migration
  def change
    add_column :pins, :is_suggestion, :boolean, default: false
    add_column :pins, :author_id, :string
    add_index :pins, :author_id
  end
end
