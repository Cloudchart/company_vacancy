class NotificationsWorker < ApplicationWorker
  include Sidetiq::Schedulable

  sidekiq_options queue: :notifications
  recurrence { minutely(Cloudchart::INSTANT_NOTIFICATIONS_TIQ) }

  def perform(last_occurrence, current_occurrence)
    Notification.all.each do |notification|
      next unless should_notify_follower?(notification)
      notify_follower(notification)
    end
  end

private

  def should_notify_follower?(notification)
    notification.updated_at < Cloudchart::INSTANT_NOTIFICATIONS_TIQ.minutes.ago ||
    notification.updated_at - notification.created_at > Cloudchart::INSTANT_NOTIFICATIONS_MAX_DELAY.minutes
  end

  def notify_follower(notification)
    notification.destroy

    # user notifications settings should be applied here
    UserMailer.activities_digest(notification.user, notification.created_at, notification.updated_at).deliver
  end

end
