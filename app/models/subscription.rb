class Subscription < ActiveRecord::Base

  serialize :types, OpenStruct

  belongs_to :user
  belongs_to :subscribable, polymorphic: true
end
