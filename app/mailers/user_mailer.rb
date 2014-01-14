class UserMailer < ActionMailer::Base
  default from: ENV['DEFAULT_FROM']

  def confirmation_instructions(user)
    @user = user
    @url = activate_url(token: user.tokens.where(name: :confirmation).first.id)
    mail to: user.email
  end
end
