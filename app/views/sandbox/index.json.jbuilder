json.array! Pin.includes(:diffbot_response, :tags, user: :tags, pinboard: :tags).insights do |pin|
  json.insight_text pin.content
  json.insight_date pin.created_at
  json.insight_tags pin.tags.map(&:name)
  json.insight_author_name pin.user.full_name
  json.insight_author_twitter_name pin.user.twitter
  json.insight_author_tags pin.user.tags.map(&:name)

  if pin.pinboard
    json.collection_name pin.pinboard.title
    json.collection_tags pin.pinboard.tags.map(&:name)
  end

  if pin.diffbot_response.try(:api) == 'article'
    if tags = pin.diffbot_response.body[:objects].first[:tags]
      json.diffbot_keywords tags.map { |tag| tag[:label].parameterize }
    end

    json.diffbot_text pin.diffbot_response.body[:objects].first[:text]
    json.diffbot_title pin.diffbot_response.body[:title]
  end
end
