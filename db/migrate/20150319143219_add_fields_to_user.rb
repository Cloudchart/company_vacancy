class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :twitter,      :string
    add_column :users, :occupation,   :string
    add_column :users, :company,      :string

    add_index :users, :twitter
  end
end
