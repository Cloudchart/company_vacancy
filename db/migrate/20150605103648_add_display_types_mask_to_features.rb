class AddDisplayTypesMaskToFeatures < ActiveRecord::Migration
  def up
    add_column :features, :display_types_mask, :integer

    say 'Starting to convert display types...'
    Feature.all.each do |feature|
      display_types = []
      display_types << :blurred if feature.is_blurred?
      display_types << :darkened if feature.is_darkened?
      feature.update(display_types: display_types)
      say 'feature updated', true
    end

    remove_column :features, :is_blurred
    remove_column :features, :is_darkened
  end

  def down
    add_column :features, :is_blurred, :boolean, default: false
    add_column :features, :is_darkened, :boolean, default: false

    say 'Starting to convert display types...'
    Feature.all.each do |feature|
      is_blurred = feature.display_types.include?(:blurred)
      is_darkened = feature.display_types.include?(:darkened)
      feature.update(is_blurred: is_blurred, is_darkened: is_darkened)
      say 'feature updated', true
    end

    remove_column :features, :display_types_mask
  end
end
