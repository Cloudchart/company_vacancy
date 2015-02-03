class MoveAdminsToRoles < ActiveRecord::Migration
  def up
    change_column :roles, :owner_id, :string, limit: 36, null: true
    change_column :roles, :owner_type, :string, null: true

    say 'Moving admins to roles...'
    User.where(is_admin: true).each do |admin|
      admin.roles.create! value: :admin
      say "Admin role for #{admin.first_name} created", true
    end

    remove_column :users, :is_admin
  end

  def down
    add_column :users, :is_admin, :boolean, default: false

    say 'Returning admin roless to users...'
    admin_roles = Role.where(value: :admin, owner: nil)
    admin_roles.each do |role|
      role.user.update(is_admin: true)
      say "User #{role.user.first_name} updated", true
    end
    admin_roles.delete_all

    change_column :roles, :owner_id, :string, limit: 36, null: false
    change_column :roles, :owner_type, :string, null: false
  end
end
