class AddKindToBlocks < ActiveRecord::Migration
  def change
    add_column :blocks, :kind, :string
  end
end
