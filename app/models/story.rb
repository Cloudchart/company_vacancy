class Story < ActiveRecord::Base
  include Uuidable

  before_validation do
    self.name = name.gsub(/[^A-Za-z0-9\-_|\s]+/i, '').squish.gsub(/\s/, '_')
    self.company_id = nil if company_id.blank?
  end

  belongs_to :company

  has_many :posts_stories, dependent: :destroy
  has_many :posts, through: :posts_stories

  validates :name, presence: true
  validates :name, uniqueness: { scope: :company_id, case_sensitive: false }

  scope :cc_plus_company, -> company_id { where(arel_table[:company_id].eq(nil).or(arel_table[:company_id].eq(company_id))) }

end
