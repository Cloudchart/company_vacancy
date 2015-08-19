class RemoveWelcomeFromPinboards < ActiveRecord::Migration
  def change
    remove_column :pinboards, :welcome, :text
  end
end
