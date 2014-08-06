class TokensController < ApplicationController
  load_and_authorize_resource
  
  def destroy
    @token.destroy
    redirect_to :back
  end

end
