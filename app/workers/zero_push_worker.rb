class ZeroPushWorker < ApplicationWorker
  include Rails.application.routes.url_helpers

  sidekiq_options queue: :notifications

  def perform(user_id, start_time, end_time)
    user = User.find(user_id)
    device_tokens = user.device_tokens.map(&:value)
    return unless device_tokens.any?

    insights = Pin.includes(:user).ready_for_broadcast(user, start_time, end_time)
    pinboards = Pinboard.includes(:user).ready_for_broadcast(user, start_time, end_time)
    pinboard_invites = Role.includes(:author, :pinboard).ready_for_broadcast(user.id, :pinboard, start_time, end_time)

    return if insights.empty? && pinboards.empty? && pinboard_invites.empty?

    if insights.size == 1 && pinboards.empty? && pinboard_invites.empty?
      insight = insights.first

      ZeroPush.notify(
        device_tokens: device_tokens,
        title: 'Insight added',
        body: "#{insight.user.full_name} added: #{insight.content}",
        url_args: [ sliced_path(insight_path(insight)) ]
      )
    elsif insights.empty? && pinboards.size == 1 && pinboard_invites.empty?
      pinboard = pinboards.first

      ZeroPush.notify(
        device_tokens: device_tokens,
        title: 'Collection created',
        body: "#{pinboard.title} by #{pinboard.user.full_name}.",
        url_args: [ sliced_path(collection_path(pinboard)) ]
      )
    elsif insights.empty? && pinboards.empty? && pinboard_invites.size == 1
      invite = pinboard_invites.first

      ZeroPush.notify(
        device_tokens: device_tokens,
        title: "Join collection",
        body: "#{invite.pinboard.title} by #{invite.author.full_name}.",
        url_args: [ sliced_path(collection_path(invite.pinboard)) ],
        label: 'Check'
      )
    else
      ZeroPush.notify(
        device_tokens: device_tokens,
        title: 'Feed updated',
        body: 'Check new insights and events.',
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
