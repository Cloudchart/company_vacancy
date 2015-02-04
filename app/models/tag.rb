class Tag < ActiveRecord::Base
  include Uuidable

  before_save do
    self.name = name.parameterize
  end

  has_paper_trail
  has_many :taggings, dependent: :destroy

  validates :name, presence: true, uniqueness: true

end
