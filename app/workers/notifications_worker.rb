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
    user = notification.user

    if user.notification_types?(:email)
      UserMailer.delay.activities_digest(user, notification.created_at, notification.updated_at)
    end

    if user.notification_types?(:safari)
      ZeroPushWorker.perform_async(user.id, notification.created_at, notification.updated_at)
    end
  end

end

Sidekiq::Cron::Job.create(
  name: 'Notifications',
  klass: 'NotificationsWorker',
  cron: "*/#{Cloudchart::INSTANT_NOTIFICATIONS_TIC} * * * *"
)
