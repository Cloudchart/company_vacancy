class CreateIndustries < ActiveRecord::Migration
  def up
    create_table :industries, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name, null: false
      t.string :parent_uuid, limit: 36
      t.integer :lft
      t.integer :rgt
      t.integer :depth

      t.timestamps
    end

    add_index :industries, :parent_uuid
    add_index :industries, :lft
    add_index :industries, :rgt
    add_index :industries, :depth
    execute 'ALTER TABLE industries ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :industries, :parent_uuid
    remove_index :industries, :lft
    remove_index :industries, :rgt
    remove_index :industries, :depth
    drop_table :industries
  end
end
