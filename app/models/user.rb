class User < ActiveRecord::Base
  include Uuidable
  
  acts_as_passport_model(confirmable: true)
  has_secure_password
  mount_uploader :avatar, AvatarUploader

  has_many :tokens, as: :tokenable, dependent: :destroy

  validates :email, presence: true, uniqueness: true

end
