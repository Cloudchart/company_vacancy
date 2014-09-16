class CreateCompanyAccessRights < ActiveRecord::Migration
  def up
    create_table :company_access_rights, id: false do |t|
      t.string :uuid, limit: 36
      t.string :user_id, limit: 36, null: false
      t.string :company_id, limit: 36, null: false
      t.string :role

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
        car = CompanyAccessRight.create(user_id: person.user_id, company_id: person.company_id)

        if index == 0 && person.is_company_owner?
          car.update(role: :owner)
        elsif index > 0 && person.is_company_owner?
          car.update(role: :editor)
        else
          car.update(role: :public_reader)
        end

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
