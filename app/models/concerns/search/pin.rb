module Search::Pin
  extend ActiveSupport::Concern

  included do
    include AlgoliaSearch

    algoliasearch id: :uuid, per_environment: true, if: :should_be_indexed?, enqueue: :trigger_sidekiq_worker do
      attribute :content, :origin, :weight, :created_at

      attribute :tags do
        tags.map do |tag|
          { name: tag.name }
        end
      end

      attribute :user do
        { name: user.full_name, twitter: user.twitter, tags: user.tags.map(&:name) }
      end

      attribute :children do
        children.where(deleted_at: nil).joins(:pinboard).map do |child|
          { pinboard: { title: child.pinboard.title, tags: child.pinboard.tags.map(&:name) } }
        end.uniq
      end

      attribute :pinboard do
        { title: pinboard.title, tags: pinboard.tags.map(&:name) } if pinboard
      end

      attribute :diffbot_response do
        if diffbot_response.try(:api) == 'article'
          tags = if diffbot_tags = diffbot_response.body[:objects].first.try(:[], :tags)
            diffbot_tags.map do |tag|
              if tag.kind_of?(Hash)
                tag[:label].try(:parameterize)
              else
                nil
              end
            end.compact
          else
            []
          end

          {
            title: diffbot_response.body[:title],
            text: diffbot_response.body[:objects].first.try(:[], :text),
            tags: tags
          }
        end
      end

    end

    def self.trigger_sidekiq_worker(record, remove)
      return if Rails.env.development?
      AlgoliaSearchWorker.perform_async(record.id, record.class.name, remove)
    end

    def should_be_indexed?
      insight? && pinboard.try(:editorial?)
    end
  end

end
