class AddPreviewToPinboard < ActiveRecord::Migration
  def change
    add_column :pinboards, :preview_uid, :string
  end
end
