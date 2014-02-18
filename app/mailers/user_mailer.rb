class UserMailer < ActionMailer::Base
  default from: ENV['DEFAULT_FROM']

  def send_company_invite(company, user, token)
    @company = company
    @user = user
    @token = token
    mail to: user.email
  end

end
