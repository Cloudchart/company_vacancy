class FriendsListWorker < ApplicationWorker

  def perform(user_id, options={})
    # find user
    user = User.find(user_id)

    # set default options
    options[:count] ||= 200

    # get friends list from twitter
    client = CloudOAuth.twitter
    client.access_token = options.delete(:access_token)
    friends = client.friends(user.twitter, options)

    # match response with app data
    friends['users'].each do |twitter_user|
      # find or create friends user
      if friend = User.find_by(twitter: twitter_user['screen_name'])
        # update association or create and autofollow
        if friends_user = user.friends_users.find_by(friend: friend)
          friends_user.update(updated_at: user.last_sign_in_at)
        else
          user.friends_users.create(friend: friend)
          user.follow(friend)
        end
      end
    end

    # clear unused friends users associations
    user.friends_users.where('updated_at < ?', user.last_sign_in_at).delete_all

    # repeat scenario if pagination present
    if (next_cursor = friends['next_cursor']) && next_cursor > 0
      FriendsListWorker.perform_async(user.id, options.merge(cursor: next_cursor, access_token: client.token.token))
    end
  end

end
