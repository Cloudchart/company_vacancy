class CreateCompanyAccessRights < ActiveRecord::Migration
  def up
    create_table :company_access_rights, id: false do |t|
      t.string :uuid, limit: 36
      t.string :user_id, limit: 36, null: false
      t.string :company_id, limit: 36, null: false
      t.string :role, null: false

      t.timestamps
    end

    add_index :company_access_rights, :user_id
    add_index :company_access_rights, :company_id
    add_index :company_access_rights, [:user_id, :company_id], unique: true
    add_index :company_access_rights, :role
    execute 'ALTER TABLE company_access_rights ADD PRIMARY KEY (uuid);'

    say 'Migrating people to access_rights'
    Company.all.each do |company|
      company.people.joins(:user).order(:created_at).each_with_index do |person, index|
        car = CompanyAccessRight.new(user_id: person.user_id, company_id: person.company_id)

        if index == 0 && person.is_company_owner?
          car.role = :owner
        elsif index > 0 && person.is_company_owner?
          car.role = :editor
        else
          car.role = :public_reader
        end

        car.save
        say "#{car.role} role for #{company.name} created", true
      end
    end
  end

  def down
    remove_index :company_access_rights, :user_id
    remove_index :company_access_rights, :company_id
    remove_index :company_access_rights, [:user_id, :company_id]
    remove_index :company_access_rights, :role
    drop_table :company_access_rights
  end
end
