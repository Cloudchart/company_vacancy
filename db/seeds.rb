# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Industries

Industry.delete_all if ENV['FORCE']

if Industry.any?
  puts '/* Industries are already seeded (if you want to reseed run with FORCE=true) */'
else
  puts '/* Seeding industries */'

  CSV.foreach('db/seeds/industries.csv') do |row|
    if row[1] == 't'
      @parent = Industry.create(name: row[0])
      puts @parent.name
    else
      child = Industry.create(name: row[0], parent_id: @parent.id)
      puts "- #{child.name}"
    end
  end
end
