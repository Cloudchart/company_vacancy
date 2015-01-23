class Post < ActiveRecord::Base
  include Uuidable
  include Blockable
  include Taggable

  VISIBILITY_WHITELIST = [:public, :trusted, :only_me].freeze

  belongs_to :owner, polymorphic: true

  has_many :posts_stories, dependent: :delete_all
  has_many :stories, through: :posts_stories
  has_many :visibilities, as: :owner, dependent: :destroy
  
  has_many :pins, as: :pinnable, dependent: :destroy

  def company
    owner if owner_type == 'Company'
  end

  def visibility
    visibilities.first
  end

end
