class FriendsListWorker < ApplicationWorker

  def perform(user_id, options={})
    # find user
    user = User.find(user_id)

    # set default options
    options[:count] ||= 1

    # get friends list from twitter
    client = CloudOAuth.twitter
    client.access_token = options.delete(:access_token)
    friends = client.friends(user.twitter, options)

    # match response with app data
    friends['users'].each do |twitter_user|
      friend = Friend.find_or_initialize_by(provider: :twitter, external_id: twitter_user['screen_name'])
      friend.full_name = twitter_user['name']
      friend.save
      user.friends << friend unless user.friends.include?(friend)
    end

    # repeat scenario if pagination present
    if (next_cursor = friends['next_cursor']) && next_cursor > 0
      FriendsListWorker.perform_async(user.id, options.merge(cursor: next_cursor, access_token: client.token.token))
    end
  end

end
