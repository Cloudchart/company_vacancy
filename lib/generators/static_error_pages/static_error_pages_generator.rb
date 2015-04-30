class StaticErrorPagesGenerator < Rails::Generators::Base
  include Rails.application.routes.url_helpers
  source_root File.expand_path('../templates', __FILE__)

  def generate_error_pages
    { not_found: 404, unprocessable_entity: 422, internal_server_error: 500, authentication_error: 403 }.each do |error_name, status_code|
      @error_name = error_name
      template 'error_page.html.erb', "public/#{status_code}.html"
    end
  end

private

  def method_missing(method_name, *args, &block)
    if self.respond_to?(method_name)
      self.send(method_name, *args, &block)
    elsif ActionController::Base.helpers.respond_to?(method_name)
      ActionController::Base.helpers.send(method_name, *args, &block)
    else
      super
    end
  end

end
