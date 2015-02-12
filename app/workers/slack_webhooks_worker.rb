class SlackWebhooksWorker < ApplicationWorker

  def perform(payload={})
    if payload['text']
      Net::HTTP.post_form(URI(ENV['SLACK_DEFAULT_WEBHOOK_URL']), payload: payload.to_json)
    end
  end

end
