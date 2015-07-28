class ChangeFieldsInFeatures < ActiveRecord::Migration
  def up    
    add_column :features, :effective_from, :date
    add_column :features, :effective_till, :date
    change_column :features, :scope, :integer, default: 0
    Feature.update_all(scope: 1)
    remove_column :features, :category
  end

  def down
    remove_column :features, :effective_from
    remove_column :features, :effective_till
    change_column :features, :scope, :string
    Feature.update_all(scope: nil)
    add_column :features, :category, :string
  end
end
