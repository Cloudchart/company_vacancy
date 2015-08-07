class IntercomEventsWorker < ApplicationWorker
  include Rails.application.routes.url_helpers

  def perform(event_name, user_id, options={})
    return unless event_name.present?

    # find user
    user = User.find(user_id)

    # instantiate ids inside options
    options.select { |key, value| key.match(/_id$/) }.each_key do |key|
      model_name = key.split(/_id$/).first
      options[model_name] = model_name.classify.constantize.find(options[key]) if options[key].present?
    end

    # symbolize_keys, add default options
    options.symbolize_keys!
    options[:should_post_to_slack] ||= true

    # create intercom event
    Intercom::Event.create(
      event_name: event_name,
      created_at: Time.now.to_i,
      user_id: user.id,
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
    when 'created-pinboard'
      result[:pinboard_url] = collection_url(options[:pinboard])
    when 'invited-person'
      result[:company_url] = company_url(options[:token].owner)
      result[:invitee_email] = options[:token].data[:email]
      result[:invitee_name] = options[:user].full_name if options[:user]
      result[:role] = options[:token].data[:role]
    when 'created-post'
      result[:post_url] = post_url(options[:post])
    when 'published-company'
      result[:company_url] = company_url(options[:company])
    when 'pinned-pin'
      result[:parent_id] = options[:pin].parent_id
      result[:pin_content] = options[:pin].content if options[:pin].content.present?
    when 'invited-user-to-app'
      result[:invitee_twitter] = options[:user].twitter
      result[:is_invitee_unicorn] = options[:user].unicorn?
    when /followed-pinboard|unfollowed-pinboard/
      result[:pinboard_url] = collection_url(options[:pinboard])
    when /followed-company|unfollowed-company/
      result[:company_url] = company_url(options[:company])
    when /followed-user|unfollowed-user/
      result[:user_url] = user_url(options[:user])
    when /followed-pin|unfollowed-pin/
      result[:pin_url] = insight_url(options[:pin])
    when 'created-pin'
      result[:pin_url] = insight_url(options[:pin])
      result[:pin_content] = options[:pin].content
    when 'suggested-pin'
      pin = options[:pin]
      result[:pin_url] = insight_url(pin)
      result[:pin_content] = pin.parent.content
      result[:parent_id] = pin.parent_id
      result[:pinboard_id] = pin.pinboard_id if pin.pinboard_id.present?
    end

    result
  end

  def get_slack_payload(event_name, user, options)
    result = {}

    case event_name
    # Created company
    # 
    when /created-company|published-company/
      company = options[:company]

      result[:text] = I18n.t("user.activities.#{event_name.underscore}",
        slack_user_params(user).merge(
          company_name: company.name,
          company_url: company_url(company)
        )
      )

    # Pinned pin
    # 
    when 'pinned-pin'
      pin = options[:pin]
      return if pin.pinboard_id.blank?

      result[:text] = I18n.t('user.activities.pinned_pin',
        slack_user_params(user).merge(
          pin_url: insight_url(pin),
          pinboard_url: collection_url(pin.pinboard),
          pinboard_title: pin.pinboard.title
        )
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

    # Suggested pin
    #
    when 'suggested-pin'
      pin = options[:pin]
      return if pin.pinboard_id.blank?

      result[:text] = I18n.t('user.activities.suggested_pin',
        slack_user_params(user).merge(
          pin_url: insight_url(pin),
          pinboard_url: collection_url(pin.pinboard),
          pinboard_title: pin.pinboard.title
        )
      )

    # Created pinboard
    # 
    when 'created-pinboard'
      pinboard = options[:pinboard]

      result[:text] = I18n.t('user.activities.created_pinboard',
        slack_user_params(user).merge(
          pinboard_url: collection_url(pin.pinboard),
          pinboard_title: pin.pinboard.title
        )
      )

    # Created post
    # 
    when 'created-post'
      post = options[:post]

      result[:text] = I18n.t('user.activities.created_post',
        slack_user_params(user).merge(
          post_url: post_url(post)
        )
      )

    # Invited user to app
    # 
    when 'invited-user-to-app'
      roles = options[:user].system_roles.map(&:value).to_sentence
      roles = 'regular user' if roles.blank?

      result[:text] = I18n.t('user.activities.invited_user_to_app',
        slack_user_params(user).merge(
          invitee_twitter: options[:user].twitter,
          invitee_twitter_url: options[:user].twitter_url,
          roles: roles
        )
      )

    # Invited person
    # 
    when 'invited-person'
      token = options[:token]
      invited_user = options[:user]
      company = token.owner

      invitee = if invited_user
        "#{invited_user.full_name} <#{token.data[:email]}>"
      else
        token.data[:email]
      end

      result[:text] = I18n.t('user.activities.invited_person',
        slack_user_params(user).merge(
          company_name: company.name,
          company_url: company_url(company),
          invitee: invitee,
          role: token.data[:role].gsub(/_/, ' ')
        )
      )

    # Followed/Unfollowed object
    #
    when /followed-pinboard|unfollowed-pinboard/
      pinboard = options[:pinboard]

      result[:text] = I18n.t("user.activities.#{event_name.underscore}",
        slack_user_params(user).merge(
          pinboard_title: pinboard.title,
          pinboard_url: collection_url(pinboard)
        )
      )
    when /followed-company|unfollowed-company/
      company = options[:company]

      result[:text] = I18n.t("user.activities.#{event_name.underscore}",
        slack_user_params(user).merge(
          company_name: company.name,
          company_url: company_url(company)
        )
      )
    when /followed-user|unfollowed-user/
      followed_user = options[:user]

      result[:text] = I18n.t("user.activities.#{event_name.underscore}",
        slack_user_params(user).merge(
          user_name: followed_user.full_name,
          user_url: user_url(followed_user)
        )
      )
    when /followed-pin|unfollowed-pin|created-pin/
      pin = options[:pin]

      result[:text] = I18n.t("user.activities.#{event_name.underscore}",
        slack_user_params(user).merge(
          pin_url: insight_url(pin)
        )
      )

      result[:attachments] = [
        fallback: result[:text],
        color: '#3dc669',
        fields: [
          value: pin.content
        ]
      ]
    end

    result.to_json
  end

  def slack_user_params(user)
    {
      name: user.full_name,
      twitter: user.twitter,
      twitter_url: user.twitter_url
    }
  end

end
