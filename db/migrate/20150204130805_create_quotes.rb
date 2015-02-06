class CreateQuotes < ActiveRecord::Migration
  def up
    create_table :quotes, id: false do |t|
      t.string  :uuid,     limit: 36
      t.string  :owner_id, limit: 36
      t.string  :owner_type

      t.text :text
      t.string :person_id, limit: 36

      t.timestamps
    end

    add_index :quotes, [:owner_id, :owner_type]
    execute 'ALTER TABLE quotes ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :quotes
  end
end
