class AddPreviewToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :preview_uid, :string
  end
end
