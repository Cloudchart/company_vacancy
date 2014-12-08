class Visibility < ActiveRecord::Base
  include Uuidable

  validates :value, presence: true

end
