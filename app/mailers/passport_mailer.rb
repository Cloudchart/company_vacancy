class PassportMailer < ActionMailer::Base
  default from: ENV['DEFAULT_FROM']

  def confirmation_instructions(user)
    @user = user
    @token_id = user.tokens.find_by(name: :confirmation).id
    mail to: user.email
  end

  def recover_instructions(user)
    @user = user
    @token_id = user.tokens.find_by(name: :recover).id
    mail to: user.email
  end

  def reconfirmation_instructions(user)
    @user = user
    token = user.tokens.find_by(name: :reconfirmation)
    @token_id = token.id
    mail to: token.data
  end

end
