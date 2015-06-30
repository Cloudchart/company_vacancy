class GuestSubscription < ActiveRecord::Base
  include Uuidable
  include Admin::GuestSubscription

  validates :email, email: true, presence: true, uniqueness: true

end
