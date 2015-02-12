class IntercomEventsWorker < ApplicationWorker
  include Rails.application.routes.url_helpers

  def perform(event_name, user_id, options={})
    options.symbolize_keys!
    options[:should_post_to_slack] ||= true

    # find user
    user = User.find(user_id)

    # instantiate ids inside options
    %w(Company Pinboard Pin Token User).each do |model_name| # TODO: select models based on ..._id re
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
    when 'pinned-post'
      result[:post_url] = post_url(options[:pin].pinnable)
      result[:pin_content] = options[:pin].content if options[:pin].content.present?
    when 'created-pinboard'
      result[:pinboard_url] = pinboard_url(options[:pinboard])
    when 'invited-person'
      result[:company_url] = company_url(options[:company])
      result[:invitee_email] = options[:token].data[:email]
      result[:invitee_name] = options[:user].full_name if options[:user]
      result[:role] = options[:token].data[:role]
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

    # Pinned post
    # 
    when 'pinned-post'
      pin = options[:pin]
      post = options[:pin].pinnable

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

    # Created Pinboard
    # 
    when 'created-pinboard'
      pinboard = options[:pinboard]

      result[:text] = I18n.t('user.activities.created_pinboard',
        name: user.full_name,
        email: user.email,
        pinboard_title: pinboard.title,
        pinboard_url: pinboard_url(pinboard)
      )

    # Invited person
    # 
    when 'invited-person'
      token = options[:token]
      invited_user = options[:user]
      company = options[:company]

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
        role: token.data[:role]
      )

    end

    result.to_json
  end

end
