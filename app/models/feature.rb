class Feature < ActiveRecord::Base
  include Uuidable

  belongs_to :featurable, polymorphic: true

  validates :featurable, presence: true
end
