module CloudProfile
  module ActivitiesHelper

    def activity_message(activity)
      preposition = activity.group_index == 1 ? 'a' : 'several'
      activity_name = activity_name(activity)
      owner_name = owner_name(activity)

      "#{preposition} #{activity_name} on #{owner_name}".html_safe
    end

  private

    def activity_name(activity)
      activity_name = activity.trackable_type
      anchor = activity.trackable ? activity.trackable_id : nil

      if activity.group_index == 1
        if activity.action == 'destroy'
          activity_name
        elsif activity.trackable
          link_to activity_name, main_app.company_path(activity.company, anchor: anchor), target: '_blank'
        else
          "#{activity_name} (which doesn't exist anymore)"
        end
      else
        activity_name.pluralize
      end
    end

    def owner_name(activity)
      owner_name = activity.company.name + "'s page"

      if activity.group_index > 1 || activity.action == 'destroy' || activity.trackable.blank?
        link_to owner_name, main_app.company_path(activity.company), target: '_blank'
      else
        owner_name
      end
    end

  end
end
