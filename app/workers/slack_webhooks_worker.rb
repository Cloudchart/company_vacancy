class SlackWebhooksWorker < ApplicationWorker

  def perform(event_name, user_id)
    user = User.find(user_id)
    result = {}

    case event_name
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
    end

    if result[:text].present?
      Net::HTTP.post_form(URI(ENV['SLACK_DEFAULT_WEBHOOK_URL']), payload: result.to_json)
    end
    
  end

end
