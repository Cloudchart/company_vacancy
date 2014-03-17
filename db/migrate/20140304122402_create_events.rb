class CreateEvents < ActiveRecord::Migration
  def up
    create_table :events, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name, null: false
      t.string :url
      t.text :sections
      t.string :location
      t.datetime :start_at
      t.datetime :end_at
      t.string :company_id, limit: 36
      t.string :author_id, limit: 36

      t.timestamps
    end

    add_index :events, :company_id
    add_index :events, :author_id
    execute 'ALTER TABLE events ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :events, :company_id
    remove_index :events, :author_id
    drop_table :events
  end
end
