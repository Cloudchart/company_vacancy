class AddOriginToPins < ActiveRecord::Migration
  def change
  	add_column :pins, :origin, :string
  end
end
