class PersonSerializer < ActiveModel::Serializer
  attributes :uuid
  attributes :user_id
  attributes :company_id
  attributes :full_name, :first_name, :last_name, :birthday, :bio
  attributes :email, :phone, :int_phone, :skype
  attributes :created_at, :updated_at
  attributes :hired_on, :fired_on, :salary, :stock_options, :occupation
  attributes :avatar_url
  
  def avatar_url
    object.user.avatar.url if object.user and object.user.avatar_stored?
  end
  
end
