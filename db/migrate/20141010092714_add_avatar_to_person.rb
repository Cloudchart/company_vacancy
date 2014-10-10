class AddAvatarToPerson < ActiveRecord::Migration
  def change
    add_column :people, :avatar_uid, :string
    
    Person.includes(:user).each do |person|
      if person.user.present?
        person.avatar = person.user.avatar if person.user.avatar_stored?
        person.save
      end
    end

  end
end
