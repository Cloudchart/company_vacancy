class AddFieldsToFeatures < ActiveRecord::Migration
  def change
    add_column :features, :title, :string
    add_column :features, :category, :string
    add_column :features, :image_uid, :string
    add_column :features, :is_active, :boolean, default: false
  end
end
