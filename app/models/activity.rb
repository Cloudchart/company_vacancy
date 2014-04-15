class Activity < ActiveRecord::Base
  include Uuidable

  belongs_to :user
  belongs_to :company
  belongs_to :trackable, polymorphic: true

  class << self
    def track_activity(user, action, trackable)
      last_activity = order(created_at: :desc).first
      company = trackable.owner if trackable.try(:owner_type) == 'Company'

      if group_activities?(user, action, trackable, company, last_activity)
        last_activity.update(group_index: last_activity.group_index + 1)
      else
        create(user: user, action: action, trackable: trackable, company: company)
      end
    end

    def by_user_or_companies(user)
      by_user_id = arel_table[:user_id].eq(user.id) 
      by_company_id = arel_table[:company_id].in(user.people.map(&:company_id))
      where(by_user_id.or(by_company_id))
    end

  private

    def group_activities?(user, action, trackable, company, last_activity)
      last_activity && last_activity.action == action && last_activity.user_id == user.id &&
      last_activity.company_id == company.try(:id) && last_activity.trackable_type == trackable.class.name
    end

  end

end
