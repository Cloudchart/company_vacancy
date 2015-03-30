class Activity < ActiveRecord::Base
  include Uuidable

  paginates_per 30

  belongs_to :user
  belongs_to :source, polymorphic: true
  belongs_to :trackable, polymorphic: true

  has_many :favorites, primary_key: :source_id, foreign_key: :favoritable_id

  scope :followed_by_user, -> id {
    joins { favorites }
    .distinct
    .where {
      favorites.user_id.eq(id) & 
      action.eq('create') &
      (trackable_type.eq('Post') | trackable_type.eq('Pin'))
    }
  }

  def self.track(user, action, trackable, source = nil)
    create(user: user, action: action, trackable: trackable, source: source)
  end

end
