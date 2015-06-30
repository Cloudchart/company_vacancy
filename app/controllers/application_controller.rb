class ApplicationController < ActionController::Base
  include RailsAdminConfigReload

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :check_browser
  after_action :store_location

  skip_after_filter :intercom_rails_auto_include, if: -> { current_user.try(:guest?) }

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  rescue_from CanCan::AccessDenied do |exception|
    if session[:after_logout]
      session[:after_logout] = nil
      respond_to do |format|
        format.html { redirect_to main_app.root_path }
        format.json { render json: { message: exception.message }, status: 404 }
      end
    else
      respond_to do |format|
        format.html { render_not_found }
        format.json { render json: { message: exception.message }, status: 404 }
      end
    end
  end

  def authenticate(options = {})
    warden.authenticate(options)
  end

  def authenticate_user(options = {})
    options[:scope] = :user
    authenticate(options)
  end

  def decorate(object, klass=nil)
    klass ||= "#{object.class}Decorator".constantize
    decorator = klass.new(object)
  end

  def should_perform_sidekiq_worker?
    %(staging production).include?(Rails.env)
  end

  def post_page_visit_to_slack_channel(page_title, page_url)
    return unless should_perform_sidekiq_worker? && request.format.html?
    SlackWebhooksWorker.perform_async('visited_page', current_user.id, page_title: page_title, page_url: page_url)
  end

private

  def check_browser
    user_agent = UserAgent.parse(request.user_agent)

    if request.path != main_app.old_browsers_path && cookies[:agree_to_browse].nil? &&
        Cloudchart::BROWSERS_WHITELIST.detect { |browser| user_agent < browser }
      redirect_to main_app.old_browsers_path
    end
  end

  def store_location
    return if user_authenticated? || !request.get? || request.xhr? || request.path == main_app.old_browsers_path
    session[:previous_path] = request.fullpath
  end

  def render_not_found
    render file: "#{Rails.root}/public/404.html", status: 404, layout: false
  end

end
