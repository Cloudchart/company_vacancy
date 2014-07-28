class TokensController < ApplicationController
  include TokenableController

  load_and_authorize_resource
  
  def destroy
    clean_company_invite_session(@token)
    @token.destroy
    redirect_to :back, notice: 'Your request has been completed.'
  end

end
