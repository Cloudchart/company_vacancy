class User < ActiveRecord::Base
  include Uuidable
  
  after_validation :postpone_email, if: proc { |user| user.email_changed? && user.persisted? }

  acts_as_passport_model
  has_secure_password
  
  has_and_belongs_to_many :friends
  has_many :tokens, as: :owner, dependent: :destroy
  has_many :people, dependent: :destroy
  has_one :avatar, as: :owner, dependent: :destroy

  accepts_nested_attributes_for :avatar, allow_destroy: true

  validates :email, presence: true, uniqueness: true, email: true
  validates :name, presence: true

private

  def postpone_email
    self.email = email_was
  end

end
