class AddTwitterToPerson < ActiveRecord::Migration
  def up
    add_column :people, :twitter, :string
    add_column :people, :is_verified, :boolean, default: false
  end

  def down
    remove_column :people, :twitter
    remove_column :people, :is_verified
  end
end
