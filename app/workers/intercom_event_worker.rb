class IntercomEventWorker < ApplicationWorker
  include Rails.application.routes.url_helpers

  def perform(event_name, user_name, user_email, options={})
    options.symbolize_keys!

    # instantiate possible options
    %w(Company User).each do |model_name|
      model_id = options[:"#{model_name.underscore}_id"]
      options[:"#{model_name.underscore}"] = model_name.constantize.find(model_id) if model_id
    end

    # create intercom event
    Intercom::Event.create(
      event_name: event_name,
      created_at: Time.now.to_i,
      email: user_email,
      metadata: get_intercom_metadata(event_name, user_name, user_email, options)
    ) if options[:user]

    # post to slack channel
    Net::HTTP.post_form(
      URI(ENV['SLACK_INTERCOM_WEBHOOK_URL']), 
      payload: get_slack_payload(event_name, user_name, user_email, options)
    )
  end

private

  def get_intercom_metadata(event_name, user_name, user_email, options={})
    result = {}

    case event_name
    when 'created-company'
      result[:company_url] = company_url(options[:company])
    end

    result
  end

  def get_slack_payload(event_name, user_name, user_email, options={})
    result = {}

    # TODO: move text to I18n
    case event_name
    when 'started-to-signup'
      result[:text] = "#{user_name} <#{user_email}> started to sign up"
    when 'created-company'
      result[:text] = "#{user_name} <#{user_email}> created <#{company_url(options[:company])}|company>"
    end

    result.to_json
  end

end
