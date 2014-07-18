module CloudProfile
  class UserSerializer < ActiveModel::Serializer

    attributes :uuid, :full_name, :email, :avatar_url
    attributes :profile_activation_url
    
    
    def profile_activation_url
      profile_activation_completion_path
    end
    
    
    def avatar_url
      object.avatar.url if object.avatar_stored?
    end

  end
end
