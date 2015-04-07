module RailsAdminConfigReload
  extend ActiveSupport::Concern

  included do
    before_filter :reload_rails_admin_config
  end

private

  def reload_rails_admin_config
    return unless controller_path =~ /rails_admin/ && Rails.env.development?
    RailsAdmin::Config::Actions.reset
    load("#{Rails.root}/config/initializers/rails_admin.rb")
  end

end
