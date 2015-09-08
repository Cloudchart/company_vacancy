module CloudApi
  module ApplicationHelper

    def facebook_share_url(url)
      uri = URI.parse('https://www.facebook.com/sharer/sharer.php')

      params = {
        display: :popup,
        u: url,
        redirect_uri: "http://#{ENV['APP_HOST']}/"
      }

      uri.query = params.to_query
      uri.to_s
    end

    def twitter_share_url(url, options={})
      uri = URI.parse('https://twitter.com/intent/tweet')
      text = truncate(options[:text].to_s, length: 90, separator: ' ', escape: false)
      text = "#{text} @#{options[:user_twitter]}" if options[:user_twitter]

      params = {
        text: text,
        url: url,
        original_referer: "http://#{ENV['APP_HOST']}/",
        via: ENV['TWITTER_APP_NAME']
      }

      uri.query = params.to_query
      uri.to_s
    end

    def parse_relations_query(query)
      return {} if query.nil? or query.blank?

      result    = {}
      key       = ''
      count     = 0
      subquery  = ''

      query.each_char do |char|
        case char
        when '{'
          subquery += char if count > 0
          count += 1
        when '}'
          count -= 1
          subquery += char if count > 0

          if count == 0
            result[key] = parse_relations_query(subquery)
            subquery = ''
          end
        when ','
          if count > 0
            subquery += char
          else
            result[key] = nil unless result[key]
            key         = ''
          end
        else
          if count > 0
            subquery += char
          else
            key += char
          end
        end
      end

      result[key] = nil unless result[key]

      result
    end


    def preload_associations(records, cache, *associations)
      Preloadable::preload(records, cache, *associations)
    end


    def json_edge!(json, edge, edges)
      json.set! edge, yield if block_given? && edges.include?(edge)
    end


    def populate_data_for_jbuilder(json, memo, source, query)
      return if source.nil?

      if source.respond_to?(:each)
        json.array! source do |child|
          populate_data_for_jbuilder(json, memo, child, query)
        end
      else
        (memo[source.class.name.pluralize.underscore.to_sym] ||= []) << source

        json.id source.uuid

        query.each do |child, child_query|
          json.set! child do
            populate_data_for_jbuilder(json, memo, source.public_send(child), child_query)
          end
        end unless query.nil?
      end
    end

  end
end
