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
    @token = Cloudchart::RFC1751.encode(token.id).downcase.gsub(/ /, '-')
    @name = token.data[:full_name]
    email = token.data[:email]
    mail to: email
  end

  def thanks_for_invite_request(token)
    @name = token.data[:full_name]
    email = token.data[:email]
    mail to: email
  end

end
