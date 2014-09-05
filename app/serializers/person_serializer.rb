class PersonSerializer < ActiveModel::Serializer

  attributes :uuid, :full_name, :first_name, :last_name, :birthday, :occupation, :avatar_url
  attributes :company_id, :is_company_owner
  attributes :created_at, :updated_at, :user_id
  attributes :hired_on, :fired_on, :salary
  attributes :email
  
  def avatar_url
    object.user.avatar.url if object.user and object.user.avatar_stored?
  end
  
end
