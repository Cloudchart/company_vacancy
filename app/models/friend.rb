class Friend < ActiveRecord::Base
  include Uuidable

  has_many :friends_users, dependent: :delete_all
  has_many :users, through: :friends_users

end
