class GuestSubscription < ActiveRecord::Base
  include Uuidable

  validates :email, email: true, presence: true, uniqueness: true

end
