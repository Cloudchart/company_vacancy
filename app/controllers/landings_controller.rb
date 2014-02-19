class LandingsController < ApplicationController
  def company_invite
    token = Token.find(params[:token_id]) rescue nil
    return redirect_to root_url, alert: t('messages.company_invite.token_not_found') unless token

    if current_user
      render :company_invite
    else
      company_invite_session = session[:company_invite] ||= []
      company_invite_session << { token_id: token.id, company_name: Person.find(token.data).company.name }
      company_invite_session.uniq!
      redirect_to token.owner ? login_path : sign_up_path
    end
  end

end
