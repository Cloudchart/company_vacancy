class Notification < ActiveRecord::Base
  include Uuidable

  belongs_to :user

end
