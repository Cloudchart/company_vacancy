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

      t.timestamps
    end

    execute 'ALTER TABLE events ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :events
  end
end
