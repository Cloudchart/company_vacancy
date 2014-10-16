class WelcomeController < ApplicationController  
  before_action :redirect_to_profile, only: :index, if: :user_authenticated?
  
  layout 'landing'

  def index
    @chart = CloudBlueprint::Chart.find(ENV['NEWSPLASH_CHART_ID'])

    pagescript_params(
      token: TokenSerializer.new(( Token.find(params[:token]) rescue Token.find_by_rfc1751(params[:token]) rescue nil )).as_json
    )
  end
  
private
  
  def redirect_to_profile
    redirect_to cloud_profile.companies_path
  end
  
end
