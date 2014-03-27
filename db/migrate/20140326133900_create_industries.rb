class CreateIndustries < ActiveRecord::Migration
  def up
    create_table :industries, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name, null: false
      t.string :parent_uuid, limit: 36

      t.timestamps
    end

    add_index :industries, :parent_uuid
    execute 'ALTER TABLE industries ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :industries, :parent_uuid
    drop_table :industries
  end
end
