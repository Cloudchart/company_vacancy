class RenameCompanyUrlToCompanySiteUrl < ActiveRecord::Migration
  def change
    rename_column :companies, :url, :site_url
  end
end
