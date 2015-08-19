class SlackWebhooksWorker < ApplicationWorker
  include Rails.application.routes.url_helpers

  IPS_MUTELIST = ['80.85.86.144', '74.86.158.106', '62.213.120.156']

  def perform(event_name, user_id, options={})
    # check event name
    event_name = event_name.to_s.underscore
    return unless event_name.present?

    # find user
    user = User.find(user_id)

    # instantiate ids inside options
    options.select { |key, value| key.match(/_id$/) }.each_key do |key|
      model_name = key.split(/_id$/).first
      options[model_name] = model_name.classify.constantize.find(options[key])
    end

    options.symbolize_keys!

    # check ips mutelist
    return if user.guest? && IPS_MUTELIST.include?(get_ip_from_request_env(options))

    # get payload based on event name
    payload = self.send("get_#{event_name}_payload", user, options) rescue {}

    # post to slack channel
    if payload[:text].present?
      Net::HTTP.post_form(URI(ENV['SLACK_DEFAULT_WEBHOOK_URL']), payload: payload.to_json)
    end

  end

private

  # payloads
  #
  def get_clicked_on_external_url_payload(user, options)
    result = {}
    return result unless pin = options[:pin]

    result[:text] = [
      "#{get_name_for_user(user, options)} clicked on external url:",
      "<#{options[:external_url]}|#{options[:external_url]}>",
      "related to <#{insight_url(pin)}|insight>"
    ].join(' ')

    if pin.content.present?
      result[:attachments] = [
        fallback: result[:text],
        color: '#3dc669',
        fields: [
          title: pin.source(:user).full_name,
          value: pin.source(:content)
        ]
      ]
    end

    result
  end

  def get_visited_page_payload(user, options)
    result = {}
    return result if user.editor? || user.admin?

    result[:text] = [
      "#{get_name_for_user(user, options)}",
      "visited <#{options[:page_url]}|#{options[:page_title]}>"
    ].join(' ')

    if attachment = options[:attachment]
      result[:attachments] = [
        fallback: result[:text],
        color: '#3dc669',
        fields: [
          title: attachment['title'],
          value: attachment['value']
        ]
      ]
    end

    result
  end

  def get_guest_subscribed_payload(user, options)
    { text: "#{get_name_for_user(user, options)} #{options[:email_address]} subscribed" }
  end

  def get_first_time_logged_in_payload(user, options)
    { text: "#{get_name_for_user(user, options)} logged in for the first time" }
  end

  def get_reported_content_payload(user, options)
    result = {}

    result[:text] = [
      "#{get_name_for_user(user, options)}",
      "reported content on <#{options[:url]}|#{options[:url]}>",
      "with the following reason: #{options[:reason]}"
    ].join(' ')

    result
  end

  def get_created_company_payload(user, options)
    result = {}

    result[:text] = [
      "#{get_name_for_user(user, options)}",
      "created <#{company_url(options[:company])}|company>"
    ].join(' ')

    result
  end

  def get_published_company_payload(user, options)
    result = {}
    company = options[:company]

    result[:text] = [
      "#{get_name_for_user(user, options)}",
      "published company: #{get_name_for_company(company)}"
    ].join(' ')

    result
  end

  def get_pinned_pin_payload(user, options)
    result = {}
    pin = options[:pin]
    return result if pin.pinboard_id.blank?

    result[:text] = [
      "#{get_name_for_user(user, options)}",
      "pinned <#{insight_url(pin)}|insight>",
      "to #{get_title_for_pinboard(pin.pinboard)} collection"
    ].join(' ')

    result[:attachments] = [
      fallback: result[:text],
      color: '#008d36',
      fields: [
        title: pin.parent.user.full_name,
        value: pin.parent.content
      ]
    ]

    if pin.content.present?
      result[:attachments] += [
        fallback: result[:text],
        color: '#3dc669',
        fields: [
          title: pin.user.full_name,
          value: pin.content
        ]
      ]
    end

    result
  end

  def get_suggested_pin_payload(user, options)
    result = {}
    pin = options[:pin]
    return result if pin.pinboard_id.blank?

    result[:text] = [
      "#{get_name_for_user(user, options)}",
      "suggested <#{insight_url(pin)}|insight>",
      "to #{get_title_for_pinboard(pin.pinboard)} collection"
    ].join(' ')

    result
  end

  def get_created_post_payload(user, options)
    result = {}
    post = options[:post]

    result[:text] = [
      "#{get_name_for_user(user, options)}",
      "created <#{post_url(post)}|post>"
    ].join(' ')

    result
  end

  def get_invited_user_to_app_payload(user, options)
    result = {}
    roles = options[:user].system_roles.map(&:value).to_sentence
    roles = 'regular user' if roles.blank?

    result[:text] = [
      "#{get_name_for_user(user, options)}",
      "invited <#{options[:user].twitter_url}|@#{options[:user].twitter}>",
      "to join #{ENV['SITE_NAME']} as #{roles}"
    ].join(' ')

    result
  end

  def get_created_pinboard_payload(user, options, action='created')
    result = {}
    pinboard = options[:pinboard]

    result[:text] = [
      "#{get_name_for_user(user, options)}",
      "#{action} #{get_title_for_pinboard(pinboard)} collection"
    ].join(' ')

    result
  end

  def get_followed_pinboard_payload(user, options)
    get_created_pinboard_payload(user, options, 'followed')
  end

  def get_unfollowed_pinboard_payload(user, options)
    get_created_pinboard_payload(user, options, 'unfollowed')
  end

  def get_followed_company_payload(user, options, action='followed')
    result = {}
    company = options[:company]

    result[:text] = [
      "#{get_name_for_user(user, options)}",
      "#{action} #{get_name_for_company(company)} company"
    ].join(' ')

    result
  end

  def get_unfollowed_company_payload(user, options)
    get_followed_company_payload(user, options, 'unfollowed')
  end

  def get_followed_user_payload(user, options, action='followed')
    result = {}
    followed_user = options[:user]

    result[:text] = [
      "#{get_name_for_user(user, options)}",
      "#{action} <#{user_url(followed_user)}|#{followed_user.full_name}> user"
    ].join(' ')

    result
  end

  def get_unfollowed_user_payload(user, options)
    get_followed_user_payload(user, options, 'unfollowed')
  end

  def get_created_pin_payload(user, options, action='created')
    result = {}
    pin = options[:pin]

    result[:text] = [
      "#{get_name_for_user(user, options)}",
      "#{action} <#{insight_url(pin)}|insight>"
    ].join(' ')

    result[:attachments] = [
      fallback: result[:text],
      color: '#3dc669',
      fields: [
        value: pin.content
      ]
    ]

    result
  end

  def get_followed_pin_payload(user, options)
    get_created_pin_payload(user, options, 'starred')
  end

  def get_unfollowed_pin_payload(user, options)
    get_created_pin_payload(user, options, 'unstarred')
  end

  # helpers
  #
  def get_name_for_company(company)
    "<#{company_url(company)}|#{company.name}>"
  end

  def get_title_for_pinboard(pinboard)
    "<#{collection_url(pinboard)}|#{pinboard.title}>"
  end

  def get_name_for_user(user, options)
    if user.guest?
      "Guest user <#{get_ip_from_request_env(options)}>"
    else
      "#{user.full_name} <#{user.twitter_url}|@#{user.twitter}>"
    end
  end

  def get_ip_from_request_env(options)
    options[:request_env].try(:[], 'action_dispatch.remote_ip')
  end

end
