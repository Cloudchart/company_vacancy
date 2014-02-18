class TokensController < ApplicationController
  def destroy
    token = Token.find(params[:id])
    token.destroy

    if session[:company_invite].present?
      session[:company_invite].reject! { |hash| hash[:token_id] == token.id }
    end

    redirect_to root_url, notice: 'Your request has been completed.'
  end

end
