class AddBlurredAndDarkenedFlagsToFeatures < ActiveRecord::Migration
  def change
    add_column :features, :is_blurred, :boolean, default: false
    add_column :features, :is_darkened, :boolean, default: false
  end
end
