class CreateTexts < ActiveRecord::Migration
  def up
    create_table :texts, id: false do |t|
      t.string :uuid, limit: 36
      t.text :content

      t.timestamps
    end

    execute "ALTER TABLE texts ADD PRIMARY KEY (uuid);"
  end

  def down
    drop_table :texts
  end
end
