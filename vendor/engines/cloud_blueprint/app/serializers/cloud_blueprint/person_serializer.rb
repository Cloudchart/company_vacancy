module CloudBlueprint
  class PersonSerializer < ActiveModel::Serializer
    
    attributes :uuid, :full_name, :first_name, :last_name, :email, :skype, :phone, :int_phone, :occupation, :bio, :birthday, :hired_on, :fired_on, :salary
    
  end
end
