class AddAccessRightsToPinboard < ActiveRecord::Migration
  def up
    add_column :pinboards, :access_rights, :string, default: 'public'
    
    add_index :pinboards, :access_rights
  end
  
  def down
    remove_column :pinboards, :access_rights
  end
end
