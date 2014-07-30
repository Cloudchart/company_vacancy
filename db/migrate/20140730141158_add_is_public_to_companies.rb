class AddIsPublicToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :is_public, :boolean, default: false
  end
end
