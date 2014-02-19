class TokensController < ApplicationController
  include TokenableController
  
  def destroy
    token = Token.find(params[:id])
    clean_session_and_destroy_token(token)
    redirect_to root_url, notice: 'Your request has been completed.'
  end

end
