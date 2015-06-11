module CloudApi
  module PinsHelper

    def facebook_share_url(url)
      uri = URI.parse("https://www.facebook.com/dialog/share")

      params = { 
        app_id: ENV['FACEBOOK_KEY'],
        display: :popup,
        href: url,
        redirect_uri: main_app.root_url
      }

      uri.query = params.to_query
      uri.to_s
    end

    def twitter_share_url(url)
      uri = URI.parse("https://twitter.com/intent/tweet")

      params = { 
        url: url,
        original_referer: main_app.root_url,
        via: :cloudchartapp
      }
      
      uri.query = params.to_query
      uri.to_s
    end

  end
end
