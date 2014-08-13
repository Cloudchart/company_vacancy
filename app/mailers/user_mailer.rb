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
    @company = token.owner
    @user = User.find(token.data[:user_id])
    token = rfc1751(token)
    @file_name = 'cloudchart_company_url_verification.txt'

    dir_location = File.join(Rails.root, 'tmp', 'attachments')
    FileUtils.mkdir_p(dir_location)
    file_location = File.join(dir_location, "#{token}.txt")
    File.open(file_location, "w") { |f| f.write(token) }
    attachments[@file_name] = File.read(file_location)
    File.delete(file_location)

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
