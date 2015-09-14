class NotificationsBreakdownWorker < ApplicationWorker

  def perform(id, class_name)
    # find object
    object = class_name.constantize.find(id)

    # find followers
    follower_ids = case class_name
    when 'Pin'
      (object.user.followers + object.pinboard.try(:followers).to_a).uniq
    when 'Pinboard'
      object.user.followers
    else
      []
    end.map(&:user_id)

    # spread notifications
    follower_ids.each { |id| Notification.touch_or_create_by!(user_id: id) }
  end

end
