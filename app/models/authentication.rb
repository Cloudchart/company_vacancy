class Authentication
  include ActiveAttr::Model

  attribute :email
  attribute :password
  attribute :user

  validates :email, presence: true
  validates :password, presence: true

  validate :must_authenticate

  def initialize(options)
    super

    profile_email = Email.includes(:user).find_by(address: options[:email])
    self.user = profile_email.user if (profile_email.present? && profile_email.user.present?)
  end

private

  def must_authenticate
    if user.blank?
      errors.add(:email, I18n.t('errors.authentication.email_doesnt_exist'))
    else
      errors.add(:password, I18n.t('errors.authentication.password_doesnt_match')) unless user.authenticate(password)
    end
  end
end
