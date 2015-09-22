class ZeroPushWorker < ApplicationWorker

  def perform(user_id, start_time, end_time)
    user = User.find(user_id)
    device_tokens = user.device_tokens.map(&:value)
    return unless device_tokens.any?

    insights = Pin.includes(:user).ready_for_broadcast(user, start_time, end_time)

    if insights.size == 1
      insight = insights.first

      ZeroPush.notify(
        device_tokens: device_tokens,
        title: 'New insight added',
        body: "#{insight.user.full_name} – #{insight.content}",
        url_args: ["insights/#{insight.id}"]
      )
    elsif insights.size > 1
      ZeroPush.notify(
        device_tokens: device_tokens,
        title: 'Feed updated',
        body: 'There are some changes in your feed.',
        url_args: ['feed'],
        label: 'Check'
      )
    end
  end

end
