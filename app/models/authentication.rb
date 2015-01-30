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

    profile_email = CloudProfile::Email.includes(:user).find_by(address: options[:email])
    self.user = profile_email.user if (profile_email.present? && profile_email.user.present?)
  end

private

  def must_authenticate
    if user.blank?
      errors[:email] << "The email does not belong to any account" 
    else
      errors[:password] << "The password is incorrect" unless user.authenticate(password)
    end
  end
end
