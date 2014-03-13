class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string :item_id, limit: 36, null: false
      t.string :item_type, null: false
      t.string :event, null: false
      t.string :whodunnit
      t.text :object
      t.text :object_changes
      t.datetime :created_at
    end

    add_index :versions, [:item_id, :item_type]
  end
end
