module Urlable
  extend ActiveSupport::Concern

  included do
    validates :url, url: true, allow_blank: true
  end

  def formatted_url
    url.match(/http:\/\/|https:\/\//) ? url : "http://#{url}"
  end

end
