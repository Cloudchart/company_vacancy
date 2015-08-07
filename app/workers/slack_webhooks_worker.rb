class SlackWebhooksWorker < ApplicationWorker

  def perform(event_name, user_id, options={})
    user = User.find(user_id)
    options.symbolize_keys!
    result = {}

    case event_name
    when 'visited_page'
      return if user.editor? || user.admin?

      if user.guest?
        result[:text] = I18n.t('user.activities.guest_visited_page',
          ip: options[:request_env]['REMOTE_ADDR'],
          page_title: options[:page_title],
          page_url: options[:page_url]
        )
      else
        result[:text] = I18n.t('user.activities.visited_page',
          name: user.full_name,
          twitter: user.twitter,
          twitter_url: user.twitter_url,
          page_title: options[:page_title],
          page_url: options[:page_url]
        )
      end

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
    when 'reported_content'
      result[:text] = I18n.t('user.activities.reported_content',
        name: user.full_name,
        twitter: user.twitter,
        twitter_url: user.twitter_url,
        reported_url: options[:url],
        reason: options[:reason]
      )
    when 'guest_subscribed'
      result[:text] = I18n.t('user.activities.guest_subscribed',
        email: options[:email]
      )
    end

    if result[:text].present?
      Net::HTTP.post_form(URI(ENV['SLACK_DEFAULT_WEBHOOK_URL']), payload: result.to_json)
    end
    
  end

end
