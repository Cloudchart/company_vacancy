class AddPreviewToUser < ActiveRecord::Migration
  def change
    add_column :users, :preview_uid, :string
  end
end
