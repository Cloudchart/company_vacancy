class RemoveIsEmptyFromCompanies < ActiveRecord::Migration
  def change
    remove_column :companies, :is_empty, :boolean, default: true
  end
end
