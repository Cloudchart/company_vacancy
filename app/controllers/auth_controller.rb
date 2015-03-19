class AuthController < ApplicationController


  def twitter
    if provider = OauthProvider.includes(:user).find_by(provider: :twitter, uid: oauth_hash.uid)

      authenticate_user!(provider.user)
      redirect_to main_app.root_path

    else

      if user = User.find_by(twitter: oauth_hash.info.nickname)

        authenticate_user!(user)
        redirect_to main_app.root_path

      else

        redirect_to main_app.root_path

      end

    end
  end


  private


  def authenticate_user!(user)
    warden.set_user(user, scope: :user)
    cookies.signed[:user_id] = { value: user.id, expires: 2.weeks.from_now }
  end


  def oauth_hash
    request.env['omniauth.auth']
  end


end
