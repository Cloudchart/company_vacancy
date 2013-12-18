class User < ActiveRecord::Base
  include Uuidable
  has_secure_password

  validates :email, presence: true, uniqueness: true
end
