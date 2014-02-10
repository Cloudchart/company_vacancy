class User < ActiveRecord::Base
  include Uuidable

  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  
  after_validation :postpone_email, if: proc { |user| user.email_changed? && user.persisted? }

  acts_as_passport_model
  has_secure_password
  mount_uploader :avatar, AvatarUploader
  
  has_many :tokens, as: :tokenable, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: EMAIL_REGEX, message: I18n.t('messages.validations.invalid_format') }

  def create_confirmation_token
    tokens.create(name: :confirmation)
  end

  def destroy_garbage_and_create_recover_token
    tokens.where(name: :recover).destroy_all
    tokens.create(name: :recover)
  end

  def destroy_garbage_and_create_reconfirmation_token(new_email)
    tokens.where(name: :reconfirmation).destroy_all
    tokens.create(name: :reconfirmation, data: new_email)
  end

  private

    def postpone_email
      self.email = email_was
    end

end
