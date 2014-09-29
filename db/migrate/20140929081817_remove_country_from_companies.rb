class RemoveCountryFromCompanies < ActiveRecord::Migration
  def change
    remove_column :companies, :country, :string
  end
end
