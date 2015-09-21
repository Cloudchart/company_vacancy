class DeviceToken < ActiveRecord::Base
  include Uuidable

  belongs_to :user

  validates :user_id, :value, presence: true

end
