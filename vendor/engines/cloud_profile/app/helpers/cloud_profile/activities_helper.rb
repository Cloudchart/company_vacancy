module CloudProfile
  module ActivitiesHelper

    def activity_message(activity)
      preposition = activity.group_type.to_s =~ /0|2/ ? 'a' : 'several'
      activity_name = activity_name(activity)
      several_times = activity.group_type == 2 ? ' several times ' : ''
      source_name = activity.source ? " on #{source_name(activity)}" : ''

      "#{preposition} #{activity_name}#{several_times}#{source_name}".html_safe
    end

  private

    def activity_name(activity)
      activity_name = activity.trackable_type
      anchor = activity.trackable ? activity.trackable_id : nil

      if activity.group_type.to_s =~ /0|2/
        if activity.trackable && activity.source
          link_to activity_name, main_app.send("#{activity.source.class.name.underscore}_path", activity.source, anchor: anchor), target: '_blank'
        elsif activity.trackable
          link_to activity_name, main_app.send("#{activity.trackable_type.underscore}_path", activity.trackable), target: '_blank'
        end
      else
        if activity.source
          activity_name.pluralize
        else
          link_to activity_name.pluralize, main_app.send("#{activity.trackable_type.underscore.pluralize}_path"), target: '_blank'
        end
      end
    end

    def source_name(activity)
      source_name = activity.subscriber_id ? 'it' : activity.source.name
      source_name += "'s page"

      if activity.group_type == 1
        link_to source_name, main_app.send("#{activity.source.class.name.underscore}_path", activity.source), target: '_blank'
      else
        source_name
      end
    end

  end
end
