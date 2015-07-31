class DiffbotResponseOwner < ActiveRecord::Base
  include Uuidable

  belongs_to :diffbot_response
  belongs_to :owner, polymorphic: true
end
