class Feature < ActiveRecord::Base
  include Uuidable

  validates :name, presence: true

end
