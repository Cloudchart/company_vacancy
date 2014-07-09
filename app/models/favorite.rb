class Favorite < ActiveRecord::Base
  include Uuidable

  belongs_to :user
  belongs_to :favoritable, polymorphic: true

end
