FactoryGirl.define do
  factory :post do
    title 'Title title title title'
    effective_from Date.today.beginning_of_month
    effective_till Date.today.end_of_month
    sequence(:position)
  end

end
