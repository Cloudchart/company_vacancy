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
      options[model_name] = model_name.classify.constantize.find(options[key]) if options[key].present?
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
    pin = options[:pin]
    return result if pin.blank?

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
          title: pin.user.full_name,
          value: pin.content
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
    result = {}
    result[:text] = I18n.t('user.activities.guest_subscribed',
      email: options[:email_address]
    )
    result
  end

  def get_first_time_logged_in_payload(user, options)
    result = {}
    result[:text] = I18n.t('user.activities.first_time_logged_in', user_params(user))
    result
  end

  def get_reported_content_payload(user, options)
    result = {}
    result[:text] = I18n.t('user.activities.reported_content',
      user_params(user).merge(
        reported_url: options[:url],
        reason: options[:reason]
      )
    )
    result
  end

  def get_created_company_payload(user, options)
    result = {}
    result[:text] = I18n.t('user.activities.created_company',
      user_params(user).merge(
        company_url: company_url(options[:company])
      )
    )
    result
  end

  def get_published_company_payload(user, options)
    result = {}
    result[:text] = I18n.t('user.activities.published_company',
      user_params(user).merge(company_params(options[:company]))
    )
    result
  end

  def get_pinned_pin_payload(user, options)
    result = {}
    pin = options[:pin]
    return result if pin.pinboard_id.blank?

    result[:text] = I18n.t('user.activities.pinned_pin',
      user_params(user).merge(pin_params(pin)).merge(pinboard_params(pin.pinboard))
    )

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

    result[:text] = I18n.t('user.activities.suggested_pin',
      user_params(user).merge(pin_params(pin)).merge(pinboard_params(pin.pinboard))
    )

    result
  end

  def get_created_pinboard_payload(user, options)
    result = {}
    pinboard = options[:pinboard]
    result[:text] = I18n.t('user.activities.created_pinboard',
      user_params(user).merge(pinboard_params(pinboard))
    )
    result
  end

  def get_created_post_payload(user, options)
    result = {}
    post = options[:post]
    result[:text] = I18n.t('user.activities.created_post',
      user_params(user).merge(
        post_url: post_url(post)
      )
    )
    result
  end

  def get_invited_user_to_app_payload(user, options)
    result = {}
    roles = options[:user].system_roles.map(&:value).to_sentence
    roles = 'regular user' if roles.blank?

    result[:text] = I18n.t('user.activities.invited_user_to_app',
      user_params(user).merge(
        invitee_twitter: options[:user].twitter,
        invitee_twitter_url: options[:user].twitter_url,
        roles: roles
      )
    )

    result
  end

  def get_followed_pinboard_payload(user, options, event_name='followed_pinboard')
    result = {}
    pinboard = options[:pinboard]
    result[:text] = I18n.t("user.activities.#{event_name}",
      user_params(user).merge(pinboard_params(pinboard))
    )
    result
  end

  def get_unfollowed_pinboard_payload(user, options)
    get_followed_pinboard_payload(user, options, 'unfollowed_pinboard')
  end

  def get_followed_company_payload(user, options, event_name='followed_company')
    result = {}
    company = options[:company]
    result[:text] = I18n.t("user.activities.#{event_name}",
      user_params(user).merge(company_params(company))
    )
    result
  end

  def get_unfollowed_company_payload(user, options)
    get_followed_company_payload(user, options, 'unfollowed_company')
  end

  def get_followed_user_payload(user, options, event_name='followed_user')
    result = {}
    followed_user = options[:user]
    result[:text] = I18n.t("user.activities.#{event_name}",
      user_params(user).merge(
        user_name: followed_user.full_name,
        user_url: user_url(followed_user)
      )
    )
    result
  end

  def get_unfollowed_user_payload(user, options)
    get_followed_user_payload(user, options, 'unfollowed_user')
  end

  def get_created_pin_payload(user, options, event_name='created_pin')
    result = {}
    pin = options[:pin]

    result[:text] = I18n.t("user.activities.#{event_name}",
      user_params(user).merge(pin_params(pin))
    )

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
    get_created_pin_payload(user, options, 'followed_pin')
  end

  def get_unfollowed_pin_payload(user, options)
    get_created_pin_payload(user, options, 'unfollowed_pin')
  end

  # params
  #
  def user_params(user)
    {
      name: user.full_name,
      twitter: user.twitter,
      twitter_url: user.twitter_url
    }
  end

  def company_params(company)
    {
      company_name: company.name,
      company_url: company_url(company)
    }
  end

  def pinboard_params(pinboard)
    {
      pinboard_title: pinboard.title,
      pinboard_url: collection_url(pinboard)
    }
  end

  def pin_params(pin)
    {
      pin_url: insight_url(pin)
    }
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
