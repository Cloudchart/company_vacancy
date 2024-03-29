class PersonSerializer < ActiveModel::Serializer
  attributes :uuid
  attributes :user_id
  attributes :company_id
  attributes :full_name, :first_name, :last_name, :birthday, :twitter, :bio
  attributes :email, :phone, :int_phone, :skype
  attributes :created_at, :updated_at
  attributes :hired_on, :fired_on, :salary, :stock_options, :occupation
  attributes :is_verified
  attributes :avatar_url

  def avatar_url
    object.avatar.thumb('512x512>').url if object.avatar_stored?
  end

end
