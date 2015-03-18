class AuthController < ApplicationController


  def twitter
    render json: request.env['omniauth.auth'].info.as_json
  end


end
