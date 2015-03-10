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
    first_name 'Dave'
    last_name 'Letuchyberg'
    email 'dave@letuchyberg.com'
    password 'letuchletuch123'
  end

end
