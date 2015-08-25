module Search::Pin
  extend ActiveSupport::Concern

  included do
    include AlgoliaSearch

    algoliasearch id: :uuid, per_environment: true, if: :insight? do
      attribute :content, :origin, :weight, :created_at

      attribute :tags do
        tags.map do |tag|
          { name: tag.name }
        end
      end

      attribute :user do
        { name: user.full_name, twitter: user.twitter, tags: user.tags.map(&:name) }
      end

      attribute :pinboard do
        { title: pinboard.title, tags: pinboard.tags.map(&:name) } if pinboard
      end

      attribute :diffbot_response do
        if diffbot_response.try(:api) == 'article'
          tags = if diffbot_tags = diffbot_response.body[:objects].first[:tags]
            diffbot_tags.map { |tag| tag[:label].parameterize }
          else
            []
          end

          {
            title: diffbot_response.body[:title],
            text: diffbot_response.body[:objects].first[:text],
            tags: tags
          }
        end
      end

    end

  end
end
