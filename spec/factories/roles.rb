FactoryGirl.define do
  factory :guest_role, class: Role do
    to_create { |instance| instance.save(validate: false) }
    value :guest
  end

end
