class Post < ActiveRecord::Base
  include Uuidable
  include Blockable
  include Taggable

  VISIBILITY_WHITELIST = [:public, :trusted, :only_me].freeze

  belongs_to :owner, polymorphic: true

  has_many :visibilities, as: :owner, dependent: :destroy

  def company
    owner if owner_type == 'Company'
  end

  def visibility
    visibilities.first
  end

end
