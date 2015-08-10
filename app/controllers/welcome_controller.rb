class WelcomeController < ApplicationController

  after_action :call_page_visit_to_slack_channel, only: [:index, :old_browsers]

  def index
    unless current_user.guest?
      if current_user.has_any_followed_users_or_pinboards?
        redirect_to main_app.feed_path
      else
        redirect_to main_app.collections_path
      end
    end
  end

  def old_browsers
    render layout: 'old_browsers'
  end

  def subscribe
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
