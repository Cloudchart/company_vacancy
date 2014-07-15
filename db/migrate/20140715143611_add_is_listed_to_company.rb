class AddIsListedToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :is_listed, :boolean, default: false
  end
end
