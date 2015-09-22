class UserMailer < ActionMailer::Base
  default from: ENV['FROM_EMAIL']

  def guest_subscription(guest_subscription)
    @guest_subscription = guest_subscription

    mail(to: @guest_subscription.email) do |format|
      format.html { render layout: 'user_mailer_' }
    end
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

    mail to: ENV['REPLY_TO_EMAIL']
  end

  def entity_invite(role, email)
    return unless email.present?

    @user = role.user
    @author = role.author
    @owner = role.owner

    send("#{role.owner_type.downcase}_invite", email)
  end

  def company_invite(email)
    mail(to: email, subject: t('user_mailer.company_invite.subject', name: @author.full_name)) do |format|
      format.html { render layout: 'user_mailer_', template: 'user_mailer/company_invite' }
    end
  end

  def pinboard_invite(email)
    mail(to: email, subject: t('user_mailer.pinboard_invite.subject', name: @author.full_name)) do |format|
      format.html { render layout: 'user_mailer_', template: 'user_mailer/pinboard_invite' }
    end
  end

  def request_pinboard_invite(user, token)
    @pinboard = token.owner
    @user = user
    @owner = @pinboard.user
    @message = token.data[:message]

    return unless email = @owner.email

    mail(to: email, subject: t('user_mailer.request_pinboard_invite.subject', name: @user.full_name)) do |format|
      format.html { render layout: 'user_mailer_' }
    end
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

  def activities_digest(user, start_time, end_time)
    return unless user.email
    @user = user
    @insights = Pin.ready_for_broadcast(user, start_time, end_time)

    mail(to: @user.email) do |format|
      format.html { render layout: 'user_mailer_' }
    end
  end

private

  def rfc1751(id)
    Cloudchart::RFC1751.encode(id)
  end

end
