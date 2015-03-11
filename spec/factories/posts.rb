FactoryGirl.define do
  factory :post do
    title 'Title title title title'
    effective_from { Date.today - rand(20).day }
    effective_till { Date.today + rand(20).day }
    sequence(:position)
  end

end
