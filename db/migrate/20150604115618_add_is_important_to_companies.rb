class AddIsImportantToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :is_important, :boolean, default: false
  end
end
