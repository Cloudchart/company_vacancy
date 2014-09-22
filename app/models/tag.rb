class Tag < ActiveRecord::Base
  include Uuidable

  has_many :taggings, dependent: :destroy

  validates :name, presence: true

end
