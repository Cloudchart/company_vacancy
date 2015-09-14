class Notification < ActiveRecord::Base
  include Uuidable

  belongs_to :user

  validates :user_id, uniqueness: true

end
