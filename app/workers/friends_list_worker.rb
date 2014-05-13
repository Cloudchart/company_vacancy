class FriendsListWorker < ApplicationWorker

  def perform(user_id, social_network_id)
    current_user = User.find(user_id)
    social_network = CloudProfile::SocialNetwork.find(social_network_id)
    provider = social_network.name
    return if current_user.friends.where(provider: provider).any?

    friends = CloudOAuth[provider].friends(social_network.access_token)

    friends.each do |friend|
      existing_friend = Friend.find_by(external_id: friend['id'])

      if existing_friend
        current_user.friends << existing_friend
      else
        full_name = if friend['name'].present?
          friend['name']
        else
          [friend['first_name'], friend['last_name']].compact.join(' ')
        end.gsub(/  /, ' ')

        current_user.friends.create(
          provider: provider,
          external_id: friend['id'],
          full_name: full_name
        )
      end
    end

  end
  
end
