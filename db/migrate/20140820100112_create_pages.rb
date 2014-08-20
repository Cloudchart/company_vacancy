class CreatePages < ActiveRecord::Migration
  def up
    create_table :pages, id: false do |t|
      t.string :uuid, limit: 36
      t.string :title
      t.text :body
      t.string :permalink

      t.timestamps
    end

    execute 'ALTER TABLE pages ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :pages
  end
end
