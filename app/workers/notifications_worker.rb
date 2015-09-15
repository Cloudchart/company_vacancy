class NotificationsWorker < ApplicationWorker
  sidekiq_options queue: :notifications

  def perform
    Notification.all.each do |notification|
      next unless should_notify_follower?(notification)
      notify_follower(notification)
    end
  end

private

  def should_notify_follower?(notification)
    notification.updated_at < Cloudchart::INSTANT_NOTIFICATIONS_TIC.minutes.ago ||
    notification.updated_at - notification.created_at > Cloudchart::INSTANT_NOTIFICATIONS_MAX_DELAY.minutes
  end

  def notify_follower(notification)
    notification.destroy

    # user notifications settings should be applied here
    UserMailer.delay.activities_digest(notification.user, notification.created_at, notification.updated_at)
  end

end
