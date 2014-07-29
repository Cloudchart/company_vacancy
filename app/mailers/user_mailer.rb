class UserMailer < ActionMailer::Base
  default from: ENV['DEFAULT_FROM']

  def company_invite(company, email, token)
    @company = company
    @user = email.try(:user)
    @token = token
    email = email.try(:address) || email
    mail to: email
  end

  def vacancy_response(vacancy, email)
    @vacancy = vacancy
    @user = email.user
    mail to: email.address
  end

  def app_invite(token)
    @token = token
    @name = @token.data['name']
    email = @token.data['email']
    mail to: email
  end

end
