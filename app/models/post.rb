class Post < ActiveRecord::Base
  include Uuidable
  include Blockable
  include Trackable

  VISIBILITY_WHITELIST = [:public, :trusted, :only_me].freeze

  belongs_to :owner, polymorphic: true
  belongs_to :company, foreign_key: :owner_id, foreign_type: 'Company'

  has_many :posts_stories, dependent: :destroy
  has_many :stories, through: :posts_stories
  has_many :visibilities, as: :owner, dependent: :destroy
  has_many :pins, as: :pinnable, dependent: :destroy

  scope :only_public, -> { joins(:visibilities).where(visibilities: { value: 'public' }) }

  def visibility
    visibilities.first
  end

end
