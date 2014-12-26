class Post < ActiveRecord::Base
  include Uuidable
  include Blockable

  VISIBILITY_WHITELIST = [:public, :trusted, :only_me].freeze

  belongs_to :owner, polymorphic: true

  has_many :posts_stories, dependent: :delete_all
  has_many :stories, through: :posts_stories
  has_many :visibilities, as: :owner, dependent: :destroy

  def company
    owner if owner_type == 'Company'
  end

  def visibility
    visibilities.first
  end

  def story_ids=(ids)
    super
    posts_stories.each { |item| item.update(position: ids.index(item.story_id)) }
  end

  def story_ids
    posts_stories.order(:position).pluck(:story_id)
  end

end
