class SlackWebhooksWorker < ApplicationWorker

  def perform(event_name, user_id, options={})
    user = User.find(user_id) if user_id
    options.symbolize_keys!
    options[:webhook_url] ||= ENV['SLACK_DEFAULT_WEBHOOK_URL']
    icon_emoji = Rails.env.staging? ? ':cloudchart_staging:' : ':cloudchart:'
    result = {}

    case event_name
    when 'visited_page'
      return if user.guest? || user.editor? || user.admin?

      result[:text] = I18n.t('user.activities.visited_page',
        name: user.full_name,
        twitter: user.twitter,
        twitter_url: user.twitter_url,
        page_title: options[:page_title],
        page_url: options[:page_url]
      )
    when 'first_time_logged_in'
      result[:text] = I18n.t('user.activities.first_time_logged_in',
        name: user.full_name,
        twitter: user.twitter
      )
    when 'added_to_queue'
      result[:text] = I18n.t('user.activities.added_to_queue',
        name: user.full_name,
        twitter: user.twitter
      )
    when 'added_details_to_queue'
      result[:text] = I18n.t('user.activities.added_details_to_queue',
        name: user.full_name,
        twitter: user.twitter
      )

      result[:attachments] = []

      [:full_name, :company, :occupation, :unverified_email].each do |attribute|
        result[:attachments] << {
          fallback: result[:text],
          color: '#3dc669',
          fields: [
            title: attribute.to_s.humanize,
            value: user.send(attribute)
          ]
        } if user.send(attribute).present?
      end
    when 'deploy_started'
      result[:text] = I18n.t('slack.webhooks.deploy_started', env: Rails.env)
      result[:icon_emoji] = icon_emoji
    when 'deploy_finished'
      result[:text] = I18n.t('slack.webhooks.deploy_finished', env: Rails.env)
      result[:icon_emoji] = icon_emoji
    end

    if result[:text].present?
      Net::HTTP.post_form(URI(options[:webhook_url]), payload: result.to_json)
    end
    
  end

end
