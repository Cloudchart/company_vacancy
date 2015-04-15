class WelcomeController < ApplicationController  
  def index
    layout = current_user.twitter.present? ? "application" : "landing"

    render layout: layout
  end
end
