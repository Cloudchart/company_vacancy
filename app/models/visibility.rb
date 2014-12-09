class Visibility < ActiveRecord::Base
  include Uuidable

  belongs_to :owner, polymorphic: true

  validates :value, presence: true

end
