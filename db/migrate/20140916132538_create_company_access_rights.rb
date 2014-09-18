class CreateCompanyAccessRights < ActiveRecord::Migration
  def up
    create_table :roles, id: false do |t|
      t.string :uuid, limit: 36
      t.string :value, null: false
      t.string :user_id, limit: 36, null: false
      t.string :owner_id, limit: 36, null: false
      t.string :owner_type, limit: 36, null: false

      t.timestamps
    end

    add_index :roles, :user_id
    add_index :roles, [:owner_id, :owner_type]
    add_index :roles, [:user_id, :owner_id], unique: true
    add_index :roles, :value
    execute 'ALTER TABLE roles ADD PRIMARY KEY (uuid);'

    say 'Migrating people access rights to roles'
    Company.all.each do |company|
      company.people.joins(:user).order(:created_at).each_with_index do |person, index|
        role = Role.new(user_id: person.user_id, owner: person.company)

        if index == 0 && person.is_company_owner?
          role.value = :owner
        elsif index > 0 && person.is_company_owner?
          role.value = :editor
        else
          role.value = :public_reader
        end

        role.save
        say "#{role.value} role for #{company.name} created", true
      end
    end
  end

  def down
    remove_index :roles, :user_id
    remove_index :roles, [:owner_id, :owner_type]
    remove_index :roles, [:user_id, :owner_id]
    remove_index :roles, :value
    drop_table :roles
  end
end
