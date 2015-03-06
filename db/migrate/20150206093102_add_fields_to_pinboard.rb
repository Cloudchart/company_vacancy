class AddFieldsToPinboard < ActiveRecord::Migration
  def change
    add_column  :pinboards, :description, :text
    add_column  :pinboards, :welcome,     :text
    add_column  :pinboards, :is_featured, :boolean
  end
end
