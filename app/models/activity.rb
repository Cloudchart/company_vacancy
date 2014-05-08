class Activity < ActiveRecord::Base
  include Uuidable

  paginates_per 20

  belongs_to :user
  belongs_to :source, polymorphic: true
  belongs_to :trackable, polymorphic: true

  class << self
    def track_activity(user, action, trackable, source = nil)
      last_activity = where(subscribable_id: nil).order(created_at: :desc).first
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
      if trackable.class == Vacancy && trackable.company.subscriptions.any?
        if group_type
          where(subscribable_id: trackable.company_id).order(created_at: :desc).first.update(group_type: group_type)
        else
          create(user: user, action: action, trackable: trackable, source: source, subscribable_id: trackable.company_id)
        end
      end
    end

    def by_user_or_companies(user)
      by_user_id = arel_table[:user_id].eq(user.id).and(arel_table[:subscribable_id].eq(nil))
      by_source_id = arel_table[:source_id].in(user.companies.map(&:id))
      by_subscribable_id = arel_table[:subscribable_id].in(user.subscriptions.map(&:subscribable_id))
      where(by_user_id.or(by_source_id).or(by_subscribable_id))
    end

  private

    def group_activities?(user, action, trackable, source, last_activity)
      last_activity && last_activity.action == action && last_activity.user_id == user.id &&
      last_activity.source_id == source.try(:id) && last_activity.trackable_type == trackable.class.name
    end

  end

end
