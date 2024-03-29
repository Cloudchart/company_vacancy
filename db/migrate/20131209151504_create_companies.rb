class CreateCompanies < ActiveRecord::Migration
  def up
    create_table :companies, id: false do |t|
      t.string  :uuid,      limit: 36
      t.string  :name
      t.string  :country
      t.boolean :is_empty,  default: true
      t.text    :description
      t.text    :sections

      t.timestamps
    end
    
    execute 'ALTER TABLE companies ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :companies
  end
end
