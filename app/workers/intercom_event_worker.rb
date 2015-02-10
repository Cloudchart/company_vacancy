class IntercomEventWorker < ApplicationWorker
  include Rails.application.routes.url_helpers

  def perform(name, user_id, company_id)
    user = User.find(user_id)
    company = Company.find(company_id)

    Intercom::Event.create(
      event_name: name,
      created_at: Time.now.to_i,
      email: user.email,
      metadata: {
        company_url: company_url(company)
      }
    )
  end

end
