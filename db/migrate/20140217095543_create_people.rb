class CreatePeople < ActiveRecord::Migration
  def up
    create_table :people, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name
      t.string :email
      t.string :phone
      t.string :user_id, limit: 36
      t.string :company_id, limit: 36, null: false

      t.timestamps
    end

    add_index :people, :user_id
    add_index :people, :company_id
    execute 'ALTER TABLE people ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :people
  end
end
