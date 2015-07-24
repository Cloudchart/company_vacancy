class UserRelayShape < BaseShape

  def url
    main_app.user_url(@source)
  end

  def avatar
    return nil unless @source.avatar_stored?
    {
      url:   @source.avatar.url
    }
  end

end
