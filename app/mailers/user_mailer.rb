class UserMailer < ActionMailer::Base
  default from: ENV['DEFAULT_FROM']

  def send_company_invite(company, user)
    @company = company
    @user = user
    @token_id = user.tokens.find_by(name: :company_invite).id
    mail to: user.email
  end

end
