class VacancyResponse < ActiveRecord::Base
  include Uuidable

  belongs_to :user
  belongs_to :vacancy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :votes, as: :destination, dependent: :destroy

  validates :content, presence: true
  
end
