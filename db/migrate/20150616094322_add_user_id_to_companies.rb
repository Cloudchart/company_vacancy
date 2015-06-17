class AddUserIdToCompanies < ActiveRecord::Migration
  def up
    add_column :companies, :user_id, :string, limit: 36
    add_index :companies, :user_id
    say 'Starting to move companies owner role to user relation...'
    Role.where(owner_type: 'Company', value: 'owner').each do |role|
      role.owner.update(user_id: role.user_id)
      role.destroy
      say "owner role for #{role.owner.name} has been moved", true
    end
  end

  def down
    say 'Starting to move companies user relation to owner role...'
    Company.where.not(user_id: nil).each do |company|
      role = Role.new(owner: company, user_id: company.user_id, value: 'owner')
      role.should_skip_pending_role!
      role.save(validate: false)
      say "owner role for #{company.name} has been created", true
    end
    remove_index :companies, :user_id
    remove_column :companies, :user_id
  end
end
