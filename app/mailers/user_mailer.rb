class UserMailer < ActionMailer::Base
  default from: ENV['DEFAULT_FROM']

  def company_invite(company, email, token)
    @company = company
    @user = email.try(:user)
    @token = rfc1751(token)
    email = email.try(:address) || email
    mail to: email
  end

  def company_url_verification(token)
    @company = Company.find(token.data)
    @user = token.owner
    @token = rfc1751(token)
    mail to: @user.email
  end

  def vacancy_response(vacancy, email)
    @vacancy = vacancy
    @user = email.user
    mail to: email.address
  end

  def app_invite(token)
    @token = rfc1751(token)
    @name = token.data[:full_name]
    email = token.data[:email]
    mail to: email
  end

  def thanks_for_invite_request(token)
    @name = token.data[:full_name]
    email = token.data[:email]
    mail to: email
  end

private

  def rfc1751(token)
    Cloudchart::RFC1751.encode(token.id).downcase.gsub(/ /, '-')
  end

end
