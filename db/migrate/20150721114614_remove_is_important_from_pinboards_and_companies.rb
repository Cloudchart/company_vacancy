class RemoveIsImportantFromPinboardsAndCompanies < ActiveRecord::Migration
  def change
    remove_column :pinboards, :is_important, :boolean, default: 0
    remove_column :companies, :is_important, :boolean, default: 0
  end
end
