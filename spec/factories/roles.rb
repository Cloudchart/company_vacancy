FactoryGirl.define do
  factory :role do
    # TODO: understand why acceptance_of_invite validation works
    to_create { |instance| instance.save(validate: false) }
  end

  factory :guest_role, class: Role do
    to_create { |instance| instance.save(validate: false) }
    value :guest
  end

end
