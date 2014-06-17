class UserMailer < ActionMailer::Base
  default from: ENV['DEFAULT_FROM']

  def send_company_invite(company, email, token)
    @company = company
    @user = email.try(:user)
    @token = token
    email = email.try(:address) || email
    mail to: email
  end

  def send_vacancy_response(vacancy, email)
    @vacancy = vacancy
    @user = email.user
    mail to: email.address
  end

end
