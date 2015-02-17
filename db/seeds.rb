# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

if ENV['GUEST_EMAIL'] && CloudProfile::Email.find_by(address: ENV['GUEST_EMAIL']).blank?
  guest = User.create!(
    first_name: 'Guest',
    last_name: 'Guest',
    emails: [CloudProfile::Email.new(address: ENV['GUEST_EMAIL'])],
    password: 'theleagueofflavour'
  )

  puts 'Guest user created'
end
