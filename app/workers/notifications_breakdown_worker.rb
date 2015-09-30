class NotificationsBreakdownWorker < ApplicationWorker

  sidekiq_options queue: :notifications

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
    follower_ids.each do |id|
      if notification = Notification.find_by(user_id: id)
        notification.touch
      else
        begin
          Notification.create(user_id: id, created_at: object.created_at)
        rescue ActiveRecord::RecordNotUnique
          Notification.find_by(user_id: id).try(:touch)
        end
      end
    end

  end

end
