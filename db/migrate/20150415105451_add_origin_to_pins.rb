class AddOriginToPins < ActiveRecord::Migration
  def change
  	add_column :pins, :origin, :text
  end
end
