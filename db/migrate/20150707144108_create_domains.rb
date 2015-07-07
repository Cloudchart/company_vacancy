class CreateDomains < ActiveRecord::Migration
  def up
    create_table :domains, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name
      t.integer :status, default: 0

      t.timestamps
    end

    execute 'ALTER TABLE domains ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :domains
  end
end
