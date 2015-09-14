class NotificationsWorker < ApplicationWorker
  include Sidetiq::Schedulable

  sidekiq_options queue: :notifications
  recurrence { minutely(Cloudchart::INSTANT_NOTIFICATIONS_TIQ) }

  def perform(last_occurrence, current_occurrence)
    Notification.all.each do |notification|
      notify_follower(notification.user_id) if should_notify_follower?(notification)
    end
  end

private

  def should_notify_follower?(notification)
    notification.updated_at < Cloudchart::INSTANT_NOTIFICATIONS_TIQ.minutes.ago ||
    notification.updated_at - notification.created_at > Cloudchart::INSTANT_NOTIFICATIONS_MAX_DELAY.minutes
  end

  def notify_follower(id)
    user = User.find(id)
    puts user.full_name
  end

end
