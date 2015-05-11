module Admin::Feature
  extend ActiveSupport::Concern

  included do

    rails_admin do
      list do
        field :insight do
          pretty_value do
            feature = bindings[:object]
            url = feature.url.present? ? feature.formatted_url : bindings[:view].main_app.post_path(feature.insight.post)
            bindings[:view].link_to feature.insight.content, url
          end
        end

        field :assigned_title do
          label 'Title'
        end

        field :assigned_image, :dragonfly do
          label 'Image'
        end

        field :category
        field :is_active
        field :is_blurred
        field :is_darkened
      end

      edit do
        field :insight do
          # associated_collection_cache_all false
          associated_collection_scope do
            Proc.new do |scope|
              scope = scope.where.not(content: nil, post: nil)
            end
          end
        end

        field :title
        field :image
        field :category
        field :url
        field :is_active
        field :is_blurred
        field :is_darkened
      end

    end

  end
  
end
