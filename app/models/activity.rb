class Activity < ActiveRecord::Base
  include Uuidable

  ACTION_WHITE_LIST = [:click].freeze

  acts_as_paranoid
  
  serialize :data

  paginates_per 30

  belongs_to :user
  belongs_to :trackable, polymorphic: true
  belongs_to :source, polymorphic: true

  has_many :favorites, primary_key: :source_id, foreign_key: :favoritable_id

  has_should_markers :should_validate_action

  validates :action, :user, :trackable, presence: true
  validates :action, inclusion: { in: ACTION_WHITE_LIST.map(&:to_s) }, on: :create, if: :should_validate_action?

  scope :followed_by_user, -> id {
    joins { favorites }
    .distinct
    .where {
      favorites.user_id.eq(id) & 
      action.eq('create') &
      (trackable_type.eq('Post') | trackable_type.eq('Pin'))
    }
  }

  def self.track(user, action, trackable, options = {})
    create(
      user: user,
      action: action,
      trackable: trackable,
      source: options[:source],
      data: options[:data]
    )
  end

end
