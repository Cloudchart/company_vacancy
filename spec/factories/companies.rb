FactoryGirl.define do
  factory :company do
    name Faker::Company.name
    description Faker::Company.catch_phrase
    slug Faker::Internet.slug
    site_url Faker::Internet.uri('http')
  end

end
