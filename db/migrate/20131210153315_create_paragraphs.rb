class CreateParagraphs < ActiveRecord::Migration
  def up
    create_table :paragraphs, id: false do |t|
      t.string :uuid, limit: 36
      t.text :content, null: false

      t.timestamps
    end

    execute 'ALTER TABLE paragraphs ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :paragraphs
  end
end
