class Favorite < ActiveRecord::Base
  include Uuidable

  belongs_to :user
  belongs_to :favoritable, polymorphic: true

  belongs_to :pinboard, foreign_key: :favoritable_id, foreign_type: Pinboard
  belongs_to :company,  foreign_key: :favoritable_id, foreign_type: Company
end
