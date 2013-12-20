class User < ActiveRecord::Base
  include Uuidable
  
  has_secure_password

  mount_uploader :avatar, AvatarUploader

  validates :email, presence: true, uniqueness: true

end
