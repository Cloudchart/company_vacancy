class AddAuthorAndPendingValueToRole < ActiveRecord::Migration
  def up
    add_column :roles, :author_id,      :string, limit: 36
    add_column :roles, :pending_value,  :string

    add_index :roles, :author_id
  end

  def down
    remove_index :roles, :author_id
    
    remove_column :roles, :author_id
    remove_column :roles, :pending_value
  end
end
