class Tag < ActiveRecord::Base
  include Uuidable

  before_save do
    self.name = name.parameterize
  end

  has_paper_trail
  has_many :taggings, dependent: :destroy
  has_many :companies, through: :taggings, source: :taggable, source_type: 'Company'
  has_many :posts, through: :taggings, source: :taggable, source_type: 'Post'

  validates :name, presence: true, uniqueness: true

  sifter :acceptable do 
    is_acceptable.eq true
  end

  scope :acceptable, -> { where{ sift :acceptable } }

  scope :available_for_user, -> user do
    user_companies = user
      .companies
      .includes(:roles, :posts).where{ roles.value.in ['owner', 'editor'] }
      .references(:all)

    company_ids = user_companies.map(&:id)
    post_ids = user_companies.map { |company| company.posts.map(&:id) }.flatten

    includes(:companies, :posts)
    .where{ 
      sift(:acceptable) |
      companies.uuid.in(company_ids) |
      posts.uuid.in(post_ids)
    }.references(:all)
  end

end
