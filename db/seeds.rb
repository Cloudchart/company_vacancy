# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Guest user
# 
unless Role.find_by(value: :guest).try(:user)
  guest = User.new(first_name: 'Guest', last_name: 'Guest')
  guest.save(validate: false)
  Role.new(value: :guest, user: guest).save(validate: false)
  puts 'Guest user created'
end
