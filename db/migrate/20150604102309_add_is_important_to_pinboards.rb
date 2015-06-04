class AddIsImportantToPinboards < ActiveRecord::Migration
  def change
    add_column :pinboards, :is_important, :boolean, default: false
  end
end