class Activity < ActiveRecord::Base
  include Uuidable

  paginates_per 20

  belongs_to :user
  belongs_to :source, polymorphic: true
  belongs_to :trackable, polymorphic: true

  class << self
    def track_activity(user, action, trackable, source = nil)
      last_activity = order(created_at: :desc).first

      if group_activities?(user, action, trackable, source, last_activity) && last_activity.trackable_id == trackable.id
        last_activity.update(group_type: 2)
      elsif group_activities?(user, action, trackable, source, last_activity)
        last_activity.update(group_type: 1)
      else
        create(user: user, action: action, trackable: trackable, source: source)
      end
    end

    def by_user_or_companies(user)
      by_user_id = arel_table[:user_id].eq(user.id) 
      by_source_id = arel_table[:source_id].in(user.people.map(&:company_id))
      where(by_user_id.or(by_source_id))
    end

  private

    def group_activities?(user, action, trackable, source, last_activity)
      last_activity && last_activity.action == action && last_activity.user_id == user.id &&
      last_activity.source_id == source.try(:id) && last_activity.trackable_type == trackable.class.name
    end

  end

end
