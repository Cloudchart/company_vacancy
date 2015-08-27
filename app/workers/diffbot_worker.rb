class DiffbotWorker < ApplicationWorker

  def perform(id, class_name, attribute_name)
    # find object
    object = class_name.constantize.find(id)
    url = object.send(attribute_name)

    # do nothing if domain is disabled
    uri = URI.parse(url)
    domain = Domain.find_by(name: uri.host)
    return if domain && domain.diffbot_api == 'disabled'

    # try to find diffbot response
    diffbot_response = DiffbotResponse.find_by(resolved_url: url)

    unless diffbot_response # call diffbot
      # get preferred api from domains
      api = if domain
        "DIFFBOT_#{domain.diffbot_api}".upcase.constantize
      else
        DIFFBOT_ANALYZE
      end

      # get response from diffbot
      response = api.get(url)
      return if response[:error]
      request = response[:request]

      # process response
      diffbot_response = DiffbotResponse.find_or_initialize_by(
        api: response[:type],
        resolved_url: request[:resolvedPageUrl] || request[:pageUrl]
      )

      if diffbot_response.new_record?
        diffbot_response.body = response
        diffbot_response.data = calculate_data(response)
        diffbot_response.save!
      end
    end

    # create association between response and passed object
    unless object.diffbot_response_owner
      object.create_diffbot_response_owner(diffbot_response: diffbot_response, attribute_name: attribute_name)
    end
  end

private

  def calculate_data(response)
    return nil unless object = response[:objects].try(:first)
    result = {}

    result[:title] = object[:title] || response[:title]

    case response[:type]
    when 'article'
      words = object[:text].to_s.split.size
      wps = Cloudchart::WORDS_PER_MINUTE / 60
      result[:estimated_time] = words / wps
    when 'video'
      result[:estimated_time] = object[:duration]
      result[:image_url] = object[:images].try(:first).try(:[], :url)
    when 'image'
      result[:image_url] = object[:url]
    when 'product'
      result[:image_url] = object[:images].try(:first).try(:[], :url)
    end

    result
  end

end
