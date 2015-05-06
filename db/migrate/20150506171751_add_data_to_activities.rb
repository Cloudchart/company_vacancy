class AddDataToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :data, :text
  end
end
