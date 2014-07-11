class VacancyResponse < ActiveRecord::Base
  include Uuidable

  before_create :set_default_status

  belongs_to :user
  belongs_to :vacancy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :votes, as: :destination, dependent: :destroy

  validates :content, presence: true

  scope :by_status, -> (status) { where(status: status) }

private

  def set_default_status
    self.status = :pending
  end
  
end
