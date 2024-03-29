class Tag < ActiveRecord::Base
  include Uuidable
  include Admin::Tag

  before_validation do
    self.name = name.parameterize
  end

  has_paper_trail
  has_many :taggings, dependent: :destroy
  has_many :companies, through: :taggings, source: :taggable, source_type: 'Company'

  validates :name, presence: true, uniqueness: true

  sifter :acceptable do 
    is_acceptable.eq true
  end

  scope :acceptable, -> { where{ sift :acceptable } }

  scope :available_for_user, -> user do
    return [] unless user.present?

    company_ids = (user.companies + user.accessed_companies.where(roles: {value: 'editor'})).map(&:id)

    joins { companies.outer }
    .where { 
      sift(:acceptable) |
      companies.uuid.in(company_ids)
    }.distinct
  end

end
