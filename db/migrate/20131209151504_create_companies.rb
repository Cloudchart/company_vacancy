class CreateCompanies < ActiveRecord::Migration
  def up
    create_table :companies, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name, null: false
      t.text :description
      t.string :logo_id, limit: 36

      t.timestamps
    end
    
    add_index :companies, :logo_id
    execute 'ALTER TABLE companies ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :companies
  end
end
