class Favorite < ActiveRecord::Base
  include Uuidable

  belongs_to :user
  belongs_to :favoritable, polymorphic: true

  belongs_to :pinboard, foreign_key: :favoritable_id, foreign_type: Pinboard.name
  belongs_to :company, foreign_key: :favoritable_id, foreign_type: Company.name
  belongs_to :favoritable_user, class_name: User.name, foreign_key: :favoritable_id, foreign_type: User.name
  belongs_to :favoritable_pin, class_name: Pin.name, foreign_key: :favoritable_id, foreign_type: Pin.name
end
