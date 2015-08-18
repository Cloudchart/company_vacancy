class FriendsUser < ActiveRecord::Base
  include Uuidable

  belongs_to :user
  belongs_to :friend

end
