class Favorite < ActiveRecord::Base
  include Uuidable

  belongs_to :user
  belongs_to :favoritable, polymorphic: true

  belongs_to :pinboard, foreign_key: :owner_id, foreign_type: Pinboard
end
