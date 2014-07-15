module CloudProfile
  module MainHelper

    def activity_message(activity)
      preposition = activity.group_type.to_s =~ /0|2/ ? '' : 'several'
      activity_name = activity_name(activity)

      # should come up with something smarter
      if activity.action == 'respond'
        preposition = "to #{preposition}"
        activity_name = "#{activity_name} vacancy"
      end

      several_times = activity.group_type == 2 ? ' several times ' : ''
      source_name = activity.source ? " on #{source_name(activity)}" : ''

      "#{preposition} #{activity_name}#{several_times}#{source_name}".html_safe
    end

  private

    def activity_name(activity)
      activity_name = activity.trackable_type
      anchor = activity.trackable ? activity.trackable_id : nil

      if activity.group_type.to_s =~ /0|2/
        activity_name = activity.trackable.try(:name) || activity_name

        if activity.trackable && activity.source
          link_to activity_name, main_app.send("#{activity.source.class.name.underscore}_path", activity.source, anchor: anchor)
        elsif activity.trackable
          link_to activity_name, main_app.send("#{activity.trackable_type.underscore}_path", activity.trackable)
        end
      else
        if activity.source
          activity_name.pluralize
        else
          # temporary crutch for company nested resources
          route_prefix = ''
          route_object = nil
          if activity.trackable_type =~ /Event|Person|Vacancy/
            route_prefix = 'company_'
            route_object = activity.trackable.company
          end

          link_to activity_name.pluralize, main_app.send("#{route_prefix}#{activity.trackable_type.underscore.pluralize}_path", route_object)
        end
      end
    end

    def source_name(activity)
      source_name = activity.subscriber_id ? 'it' : activity.source.name
      source_name += "'s page"

      if activity.group_type == 1
        link_to source_name, main_app.send("#{activity.source.class.name.underscore}_path", activity.source)
      else
        source_name
      end
    end

  end
end
