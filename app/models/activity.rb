class Activity < ActiveRecord::Base
  include Uuidable

  serialize :data

  paginates_per 30

  belongs_to :user
  belongs_to :trackable, polymorphic: true
  belongs_to :source, polymorphic: true

  has_many :favorites, primary_key: :source_id, foreign_key: :favoritable_id

  validates :action, :user, :trackable, presence: true

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
