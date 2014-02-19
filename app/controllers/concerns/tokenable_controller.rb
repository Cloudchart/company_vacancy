module TokenableController
  extend ActiveSupport::Concern

private

  def clean_session_and_destroy_token(token)
    if session[:company_invite].present?
      session[:company_invite].reject! { |hash| hash[:token_id] == token.id }
    end
    token.destroy    
  end

end
