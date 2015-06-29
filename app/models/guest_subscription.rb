class GuestSubscription < ActiveRecord::Base
  include Uuidable

  validates :email, email: true, presence: true

end
