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
    SlackWebhooksWorker.perform_async(event_name, user_id, options) if options[:should_post_to_slack]
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

end
