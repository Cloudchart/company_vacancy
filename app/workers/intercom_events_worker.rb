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
    when 'pinned-post'
      result[:post_url] = post_url(options[:pin].pinnable)
      result[:pin_content] = options[:pin].content if options[:pin].content.present?
    when 'created-pinboard'
      result[:pinboard_url] = pinboard_url(options[:pinboard])
    when 'invited-person'
      result[:company_url] = company_url(options[:token].owner)
      result[:invitee_email] = options[:token].data[:email]
      result[:invitee_name] = options[:user].full_name if options[:user]
      result[:role] = options[:token].data[:role]
    when 'created-post'
      result[:post_url] = post_url(options[:post])
    when 'published-company'
      result[:company_url] = company_url(options[:company])
    when 'pinned-post-pin'
      result[:post_url] = post_url(options[:pin].pinnable)
      result[:parent_id] = options[:pin].parent_id
      result[:pin_content] = options[:pin].content if options[:pin].content.present?
    end

    result
  end

  def get_slack_payload(event_name, user, options)
    result = {}

    case event_name
    # Created company
    # 
    when 'created-company'
      result[:text] = I18n.t('user.activities.created_company',
        name: user.full_name,
        email: user.email,
        company_url: company_url(options[:company])
      )

    # Published company
    # 
    when 'published-company'
      company = options[:company]

      result[:text] = I18n.t('user.activities.published_company',
        name: user.full_name,
        email: user.email,
        company_name: company.name,
        company_url: company_url(company)
      )

    # Pinned post
    # 
    when 'pinned-post'
      pin = options[:pin]
      post = pin.pinnable

      result[:text] = I18n.t('user.activities.pinned_post',
        name: user.full_name,
        email: user.email,
        post_title: post.title.present? ? post.title : post.effective_from,
        post_url: post_url(post)
      )

      if pin.content.present?
        result[:attachments] = [
          fallback: result[:text],
          color: '#3dc669',
          fields: [
            title: I18n.t('lexicon.comment'),
            value: pin.content
          ]
        ]
      end

    # Pinned pin
    # 
    when 'pinned-post-pin'
      pin = options[:pin]
      parent = pin.parent
      parent_user = parent.user
      post = pin.pinnable

      result[:text] = I18n.t('user.activities.pinned_pin',
        name: user.full_name,
        email: user.email,
        parent_user_name: parent_user.full_name,
        parent_user_email: parent_user.email,
        post_title: post.title.present? ? post.title : post.effective_from,
        post_url: post_url(post)
      )

      result[:attachments] = [
        fallback: result[:text],
        color: '#008d36',
        fields: [
          title: parent_user.full_name,
          value: parent.content
        ]
      ]

      if pin.content.present?
        result[:attachments] += [
          fallback: result[:text],
          color: '#3dc669',
          fields: [
            title: user.full_name,
            value: pin.content
          ]   
        ]
      end

    # Created pinboard
    # 
    when 'created-pinboard'
      pinboard = options[:pinboard]

      result[:text] = I18n.t('user.activities.created_pinboard',
        name: user.full_name,
        email: user.email,
        pinboard_title: pinboard.title,
        pinboard_url: pinboard_url(pinboard)
      )

    # Created post
    # 
    when 'created-post'
      post = options[:post]

      result[:text] = I18n.t('user.activities.created_post',
        name: user.full_name,
        email: user.email,
        post_url: post_url(post)
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
        name: user.full_name,
        email: user.email,
        company_name: company.name,
        company_url: company_url(company),
        invitee: invitee,
        role: token.data[:role].gsub(/_/, ' ')
      )

    end

    result.to_json
  end

end
