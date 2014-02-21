class User < ActiveRecord::Base
  include Uuidable

  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  
  after_validation :postpone_email, if: proc { |user| user.email_changed? && user.persisted? }

  acts_as_passport_model
  has_secure_password
  
  has_many :tokens, as: :owner, dependent: :destroy
  has_many :people, dependent: :destroy
  has_one :avatar, as: :owner, dependent: :destroy

  accepts_nested_attributes_for :avatar, allow_destroy: true

  validates :email, presence: true, uniqueness: true, format: { with: EMAIL_REGEX, message: I18n.t('messages.validations.invalid_format') }
  validates :name, presence: true

private

  def postpone_email
    self.email = email_was
  end

end
