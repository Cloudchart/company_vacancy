class ZeroPushWorker < ApplicationWorker
  include Rails.application.routes.url_helpers

  sidekiq_options queue: :notifications

  def perform(user_id, start_time, end_time)
    user = User.find(user_id)
    device_tokens = user.device_tokens.map(&:value)
    return unless device_tokens.any?

    insights = Pin.includes(:user).ready_for_broadcast(user, start_time, end_time)
    pinboards = Pinboard.includes(:user).ready_for_broadcast(user, start_time, end_time)

    if insights.size == 1 && pinboards.empty?
      insight = insights.first

      ZeroPush.notify(
        device_tokens: device_tokens,
        title: 'Insight added',
        body: "#{insight.user.full_name} added new insight: #{insight.content}",
        url_args: [ sliced_path(insight_path(insight)) ]
      )
    elsif pinboards.size == 1 && insights.empty?
      pinboard = pinboards.first

      ZeroPush.notify(
        device_tokens: device_tokens,
        title: 'Collection created',
        body: "#{pinboard.user.full_name} created collection: #{pinboard.title}.",
        url_args: [ sliced_path(collection_path(pinboard)) ]
      )
    elsif insights.size > 1 || pinboards.size > 1 || (insights.any? && pinboards.any?)
      ZeroPush.notify(
        device_tokens: device_tokens,
        title: 'Feed updated',
        body: 'There are some changes in your feed.',
        url_args: [ sliced_path(feed_path) ],
        label: 'Check'
      )
    end
  end

private

  def sliced_path(path)
    path.remove(/^\//)
  end

end
