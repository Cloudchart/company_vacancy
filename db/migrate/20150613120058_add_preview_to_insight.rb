class AddPreviewToInsight < ActiveRecord::Migration
  def change
    add_column :pins, :preview_uid, :string
  end
end
