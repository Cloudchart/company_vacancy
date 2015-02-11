class IntercomEventWorker < ApplicationWorker
  include Rails.application.routes.url_helpers

  def perform(name, user_id, company_id)
    # find records
    user = User.find(user_id)
    company = Company.find(company_id)

    # create intercom event
    Intercom::Event.create(
      event_name: name,
      created_at: Time.now.to_i,
      email: user.email,
      metadata: {
        company_url: company_url(company)
      }
    )

    # post to slack #intercom channel
    uri = URI(ENV['SLACK_INTERCOM_WEBHOOK_URL'])
    params = { text: "#{user.full_name} created <#{company_url(company)}|company>" }
    res = Net::HTTP.post_form(uri, payload: params.to_json)

  end

end
