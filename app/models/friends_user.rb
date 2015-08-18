class FriendsUser < ActiveRecord::Base
  include Uuidable

  serialize :data

  belongs_to :user
  belongs_to :friend, class_name: User.name

end
