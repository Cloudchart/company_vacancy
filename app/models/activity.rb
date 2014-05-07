class Activity < ActiveRecord::Base
  include Uuidable

  paginates_per 20

  belongs_to :user
  belongs_to :source, polymorphic: true
  belongs_to :trackable, polymorphic: true

  class << self
    def track_activity(user, action, trackable, source = nil)
      last_activity = where(subscriber_id: nil).order(created_at: :desc).first
      group_type = nil

      if group_activities?(user, action, trackable, source, last_activity) && last_activity.trackable_id == trackable.id
        group_type = 2
        last_activity.update(group_type: group_type)
      elsif group_activities?(user, action, trackable, source, last_activity)
        group_type = 1
        last_activity.update(group_type: group_type)
      else
        create(user: user, action: action, trackable: trackable, source: source)
      end

      # duplicate activity for subscribers
      # only for vacancy activities so far
      if trackable.class == Vacancy
        trackable.company.subscriptions.map(&:user_id).each do |user_id|
          if group_type
            where(subscriber_id: user_id).order(created_at: :desc).first.update(group_type: group_type)
          else
            create(user: user, action: action, trackable: trackable, source: source, subscriber_id: user_id)
          end
        end
      end
    end

    def by_user_or_companies(user)
      by_user_id = arel_table[:user_id].eq(user.id).and(arel_table[:subscriber_id].eq(nil))
      by_source_id = arel_table[:source_id].in(user.companies.map(&:id))
      by_subscriber_id = arel_table[:subscriber_id].eq(user.id)
      where(by_user_id.or(by_source_id).or(by_subscriber_id))
    end

  private

    def group_activities?(user, action, trackable, source, last_activity)
      last_activity && last_activity.action == action && last_activity.user_id == user.id &&
      last_activity.source_id == source.try(:id) && last_activity.trackable_type == trackable.class.name
    end

  end

end
