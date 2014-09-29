class RenameIsListedToIsPublishedInCompanies < ActiveRecord::Migration
  def change
    rename_column :companies, :is_listed, :is_published
  end
end
