class DiffbotWorker < ApplicationWorker

  def perform(object_id, object_type, attribute_name, url)
    # find object
    object = object_type.classify.constantize.find(object_id)

    # get response from diffbot
    response = DIFFBOT_ANALYZE.get(url)
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

    # create or update association with passed object
    if object.diffbot_response_owner.nil?
      object.create_diffbot_response_owner(diffbot_response: diffbot_response, attribute_name: attribute_name)
    else
      object.diffbot_response_owner.update(diffbot_response: diffbot_response, attribute_name: attribute_name)
    end
  end

private

  def calculate_data(response)
    result = {}
    return result unless object = response[:objects].first

    result[:estimated_time] = case response[:type]
    when 'article'
      words = object[:text].to_s.split.size
      wps = Cloudchart::WORDS_PER_MINUTE / 60
      words / wps
    when 'video'
      object[:duration]
    else
      0
    end

    result
  end

end
