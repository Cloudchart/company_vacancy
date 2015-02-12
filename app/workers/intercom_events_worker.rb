class IntercomEventsWorker < ApplicationWorker
  include Rails.application.routes.url_helpers

  def perform(event_name, user_id, options={})
    options.symbolize_keys!
    options[:should_post_to_slack] ||= true

    # find user
    user = User.find(user_id)

    # instantiate ids inside options
    %w(Company).each do |model_name|
      model_id = options[:"#{model_name.underscore}_id"]
      options[:"#{model_name.underscore}"] = model_name.constantize.find(model_id) if model_id
    end

    # create intercom event
    Intercom::Event.create(
      event_name: event_name,
      created_at: Time.now.to_i,
      email: user.email,
      metadata: get_intercom_metadata(event_name, user, options)
    )

    # post to slack channel
    Net::HTTP.post_form(
      URI(ENV['SLACK_INTERCOM_WEBHOOK_URL']), 
      payload: get_slack_payload(event_name, user, options)
    ) if options[:should_post_to_slack]
  end

private

  def get_intercom_metadata(event_name, user, options)
    result = {}

    case event_name
    when 'created-company'
      result[:company_url] = company_url(options[:company])
    end

    result
  end

  def get_slack_payload(event_name, user, options)
    result = {}

    # TODO: move text to I18n
    case event_name
    when 'created-company'
      result[:text] = I18n.t('user.activities.created_company',
        name: user.full_name,
        email: user.email,
        url: company_url(options[:company])
      )
    end

    result.to_json
  end

end
