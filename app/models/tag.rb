class Tag < ActiveRecord::Base
  include Uuidable

  before_validation do
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
    return [] unless user.present?

    company_ids = user.companies.select(:uuid).joins(:roles).where{ roles.value.in ['owner', 'editor'] }
    post_ids = Post.select(:uuid).where{ owner_id.in company_ids }

    joins { companies.outer }
    .joins { posts.outer }
    .where{ 
      sift(:acceptable) |
      companies.uuid.in(company_ids) |
      posts.uuid.in(post_ids)
    }.distinct
  end

end
