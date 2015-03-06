class Feature < ActiveRecord::Base
  include Uuidable

  has_paper_trail
  has_many :votes, as: :destination, dependent: :destroy

  validates :name, presence: true

end
