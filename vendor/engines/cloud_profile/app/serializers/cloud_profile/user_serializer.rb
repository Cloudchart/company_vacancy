module CloudProfile
  class UserSerializer < ActiveModel::Serializer

    attributes :uuid, :full_name, :email, :avatar, :avatar_url
    attributes :profile_activation_url
    
    
    def profile_activation_url
      profile_activation_completion_path
    end
    
    
    def avatar_url
      avatar.url rescue nil
    end

  end
end
