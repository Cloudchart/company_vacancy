class CreatePeople < ActiveRecord::Migration
  def up
    create_table :people, id: false do |t|
      t.string :uuid, limit: 36
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email
      t.string :occupation
      t.string :phone
      t.string :user_id, limit: 36
      t.string :company_id, limit: 36, null: false
      t.boolean :is_company_owner, default: false

      t.timestamps
    end

    add_index :people, :user_id
    add_index :people, :company_id
    execute 'ALTER TABLE people ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :people, :user_id
    remove_index :people, :company_id
    drop_table :people
  end
end
