class AddShortNameToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :short_name, :string
    add_index :companies, :short_name, unique: true
  end
end
