class WelcomeController < ApplicationController

  before_action :call_page_visit_to_slack_channel, only: [:index, :old_browsers]

  def index
    render layout: 'guest' unless user_authenticated?
  end

  def old_browsers
    render layout: 'old_browsers'
  end

private

  def call_page_visit_to_slack_channel
    case action_name
    when 'index'
      page_title = 'Welcome page'
      page_url = main_app.root_url
    when 'old_browsers'
      page_title = 'Old browsers page'
      page_url = main_app.old_browsers_url
    end

    post_page_visit_to_slack_channel(page_title, page_url)
  end

end
