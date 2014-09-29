class DropIndustries < ActiveRecord::Migration
  def up
    remove_index :industries, :parent_id
    drop_table :industries
  end

  def down
    create_table :industries, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name, null: false
      t.string :parent_id, limit: 36

      t.timestamps
    end

    add_index :industries, :parent_id
    execute 'ALTER TABLE industries ADD PRIMARY KEY (uuid);'
  end
end
