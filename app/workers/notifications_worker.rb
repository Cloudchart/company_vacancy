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

    # TODO: user notifications settings should be applied here
    if user.email
      UserMailer.delay.activities_digest(user, notification.created_at, notification.updated_at)
    end

    if user.device_tokens.any?
      ZeroPush.notify(
        device_tokens: user.device_tokens.map(&:value),
        title: 'Feed updated',
        body: 'There are some changes in your feed.',
        url_args: ['feed'],
        label: 'Check'
      )
    end

  end

end

Sidekiq::Cron::Job.create(
  name: 'Notifications',
  klass: 'NotificationsWorker',
  cron: "*/#{Cloudchart::INSTANT_NOTIFICATIONS_TIC} * * * *"
)
