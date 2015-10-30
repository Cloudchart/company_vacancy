class AddReactionToPins < ActiveRecord::Migration
  def change
    add_column :pins, :positive_reaction, :text
    add_column :pins, :negative_reaction, :text
  end
end
