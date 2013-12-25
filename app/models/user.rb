class User < ActiveRecord::Base
  include Uuidable
  
  has_secure_password

  has_many :tokens, as: :tokenable, dependent: :destroy

  mount_uploader :avatar, AvatarUploader

  validates :email, presence: true, uniqueness: true

end
