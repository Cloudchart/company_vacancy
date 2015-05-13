class UserMailer < ActionMailer::Base
  default from: ENV['FROM_EMAIL']

  def company_invite(email, token)
    @company = token.owner
    @user = email.try(:user)
    @token = rfc1751(token.id).parameterize
    email = email.try(:address) || email
    
    mail to: email
  end

  def company_url_verification(token)
    @company = token.owner
    @user = User.find(token.data[:user_id])
    file_name = "#{@company.humanized_id}.txt"
    attachments[file_name] = File.read(File.join(Rails.root, 'tmp', 'verifications', file_name))

    mail to: @user.email
  end

  def vacancy_response(vacancy, email)
    @vacancy = vacancy
    @user = email.user

    mail to: email.address
  end

  def app_invite(token)
    @token = rfc1751(token.id).parameterize
    @code = rfc1751(token.id)
    @name = token.data[:full_name]

    email = token.data[:email]
    mail to: email
  end

  def thanks_for_invite_request(token)
    @name = token.data[:full_name]
    email = token.data[:email]

    mail to: email
  end

  def interview_acceptance(interview)
    @interview = interview

    mail to: 'anton@cloudchart.co'
  end

  def pinboard_invite(email, token)
    @pinboard = token.owner
    @user = email.try(:user)
    @token = rfc1751(token.id).parameterize

    email = email.try(:address) || email
    mail to: email
  end

  def app_invite_(user)
    return unless email = user.unverified_email || user.email
    @user = user

    mail(to: email) do |format|
      format.html { render layout: 'user_mailer_' }
    end
  end

  def custom_invite(user, email_template, inviter)
    @user = user
    @email_template = email_template
    @inviter = inviter

    mail(to: email_template.email, subject: email_template.subject) do |format|
      format.html { render layout: 'user_mailer_' }
    end
  end

private

  def rfc1751(id)
    Cloudchart::RFC1751.encode(id)
  end

end
