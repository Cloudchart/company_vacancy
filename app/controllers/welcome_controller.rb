class WelcomeController < ApplicationController
  def index
    render layout: 'guest' unless user_authenticated?
  end
end
