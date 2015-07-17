class AddUrlToFeatures < ActiveRecord::Migration
  def change
    add_column :features, :url, :string
  end
end
