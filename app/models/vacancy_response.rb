class VacancyResponse < ActiveRecord::Base
  include Uuidable

  belongs_to :user
  belongs_to :vacancy

  validates :content, presence: true
end
