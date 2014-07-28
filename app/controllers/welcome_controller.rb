class WelcomeController < ApplicationController
  
  skip_before_action :require_authenticated_user!, only: :index
  before_action :redirect_to_profile, only: :index, if: :user_authenticated?
  
  private
  
  def redirect_to_profile
    redirect_to cloud_profile.root_path
  end
  
end
