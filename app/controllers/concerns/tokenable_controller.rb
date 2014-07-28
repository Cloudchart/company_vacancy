module TokenableController
  extend ActiveSupport::Concern

private

  def clean_company_invite_session(token)
    if token && session[:company_invite].present?
      session[:company_invite].reject! { |company_invite| company_invite[:token_id] == token.id }
    end
  end

end
