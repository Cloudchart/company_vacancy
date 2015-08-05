class DiffbotResponseOwner < ActiveRecord::Base
  include Uuidable

  belongs_to :diffbot_response
  belongs_to :owner, polymorphic: true

  validates :attribute_name, presence: true

end
