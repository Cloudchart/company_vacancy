FactoryGirl.define do
  factory :guest, class: User do
    to_create { |instance| instance.save(validate: false) }

    first_name 'Guest'
    last_name 'Guest' 

    after(:create) do |user|
      create(:guest_role, user: user)
    end
  end

  factory :user do
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    email Faker::Internet.email
    password Faker::Internet.password
  end

end
