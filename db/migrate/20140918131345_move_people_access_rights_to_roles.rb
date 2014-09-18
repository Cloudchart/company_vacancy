class MovePeopleAccessRightsToRoles < ActiveRecord::Migration
  def up
    unless Role.any?
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

    remove_column :people, :is_company_owner    
  end

  def down
    add_column :people, :is_company_owner, :boolean, default: false

    say 'Reverting access rights to people'
    Role.all.select { |role| role.value =~ /owner|editor/ }.each do |role|
      person = role.owner.people.order(:created_at).first
      person.update(is_company_owner: true)
      say "#{person.full_name} became owner", true
    end
  end
end
