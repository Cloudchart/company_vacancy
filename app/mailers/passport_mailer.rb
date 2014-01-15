class PassportMailer < Passport::Mailers::Base
  default from: ENV['DEFAULT_FROM']
end
