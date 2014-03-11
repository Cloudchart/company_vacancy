class Feature < ActiveRecord::Base
  include Uuidable

  has_many :votes, as: :destination, dependent: :destroy

  validates :name, presence: true

end
