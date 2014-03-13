class CreateVacancies < ActiveRecord::Migration
  def up
    create_table :vacancies, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name, null: false
      t.text :description
      t.string :salary
      t.string :location
      t.string :company_id, limit: 36, null: false
      t.text :settings

      t.timestamps
    end

    add_index :vacancies, :company_id
    execute 'ALTER TABLE vacancies ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :vacancies, :company_id
    drop_table :vacancies
  end

end
