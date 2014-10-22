class DropCarrierwaveRelatedTables < ActiveRecord::Migration
  def up
    drop_table :images
    drop_table :block_images
  end

  def down
    say 'this migration cannot be rolled back'
  end
end
