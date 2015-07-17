class ChangeFeatures < ActiveRecord::Migration
  def up
    drop_table :features

    create_table :features, id: false do |t|
      t.string :uuid, limit: 36
      t.string :featurable_id, limit: 36, null: false
      t.string :featurable_type, null: false
      t.string :scope

      t.timestamps
    end

    add_index :features, [:featurable_id, :featurable_type]
    execute 'ALTER TABLE features ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :features, [:featurable_id, :featurable_type]
    drop_table :features

    create_table :features, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name, null: false
      t.text :description
      t.integer :votes_total

      t.timestamps
    end
    
    execute 'ALTER TABLE features ADD PRIMARY KEY (uuid);'
  end
end