class AddOwnerToParagraph < ActiveRecord::Migration
  def change
    add_column :paragraphs, :owner_id, :string, limit: 36
    add_column :paragraphs, :owner_type, :string
  end
end
