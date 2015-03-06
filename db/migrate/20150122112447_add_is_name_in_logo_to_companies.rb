class AddIsNameInLogoToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :is_name_in_logo, :boolean, default: false
  end
end
