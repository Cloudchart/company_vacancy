class RenamePermalinkToSlugInPagesAndCompanies < ActiveRecord::Migration
  def up
    rename_column :pages, :permalink, :slug
    add_index :pages, :slug, unique: true
    rename_column :companies, :short_name, :slug
  end

  def down
    rename_column :pages, :slug, :permalink
    rename_column :companies, :slug, :short_name
  end
end
