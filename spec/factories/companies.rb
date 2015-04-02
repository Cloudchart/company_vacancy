FactoryGirl.define do
  factory :company do
    name { Faker::Company.name }
    description { Faker::Company.catch_phrase }
    sequence(:slug) { |n| "fake-slug-#{n}" }
    site_url { Faker::Internet.uri('http') }
  end

end
