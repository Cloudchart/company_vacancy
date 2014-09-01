class LandingsController < ApplicationController
  skip_before_action :require_authenticated_user!

  def company_invite
    token = Token.find_by_rfc1751(params[:token]) || Token.find(params[:token])
    @company = token.owner
    @author = User.find(token.data[:author_id])
  end

end
