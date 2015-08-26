require 'digest'

module CloudApi
  class ApplicationController < ::ApplicationController

  protected

    def render_cached_main_json(options = {})
      if current_user.guest?
        sha256        = Digest::SHA1.new
        sha256.update params.to_s
        key           = sha256.digest
        cached_render = Rails.cache.read(key)
        if cached_render
          render json: cached_render
        else
          render './main'
          Rails.cache.write(key, response.body, options)
        end
      else
        render './main'
      end
    end

  end
end
