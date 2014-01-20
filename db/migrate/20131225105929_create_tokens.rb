class CreateTokens < ActiveRecord::Migration
  def up
    create_table :tokens, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name, null: false
      t.text :data
      t.string :tokenable_id, limit: 36
      t.string :tokenable_type

      t.timestamps
    end

    execute 'ALTER TABLE tokens ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :tokens
  end
end
