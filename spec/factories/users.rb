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
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:email) { |n| "fake#{n}@mail.com" }
    password { Faker::Internet.password }

    factory :user_with_roles do
      transient do
        value :owner
        owner nil
      end

      after(:create) do |user, evaluator|
        create(:role, value: evaluator.value, owner: evaluator.owner, user: user)
      end
    end

  end

end
