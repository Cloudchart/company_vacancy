class UserMailer < ActionMailer::Base
  default from: "confirm@cloudchart.com"

  def confirmation_instructions(user)
    @name = user.name
    @url = activate_url(token: user.tokens.where(name: :confirmation).first.id)
    mail to: user.email
  end
end
