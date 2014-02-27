class CreateTokens < ActiveRecord::Migration
  def up
    create_table :tokens, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name, null: false
      t.text :data
      t.string :owner_id, limit: 36
      t.string :owner_type

      t.timestamps
    end

    add_index :tokens, [:owner_id, :owner_type]
    execute 'ALTER TABLE tokens ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :tokens
  end
end
