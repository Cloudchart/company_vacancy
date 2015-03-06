FactoryGirl.define do
  factory :guest, class: User do
    first_name 'Guest'
    last_name 'Guest'
  end

end
