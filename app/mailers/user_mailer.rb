class UserMailer < ActionMailer::Base
  default from: ENV['DEFAULT_FROM']

  def send_company_invite(company, email, token)
    @company = company
    @user = email.try(:user)
    @token = token
    email = email.try(:address) || email
    mail to: email
  end

end
