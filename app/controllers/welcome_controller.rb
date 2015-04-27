class WelcomeController < ApplicationController
  def index
    render layout: 'guest' unless user_authenticated?
  end

  def old_browsers
    render layout: 'old_browsers'
  end
end
