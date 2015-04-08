module Admin::Feature
  extend ActiveSupport::Concern

  included do

    rails_admin do
      list do
        field :insight do
          pretty_value do
            bindings[:view].link_to bindings[:object].insight.content, bindings[:view].main_app.post_path(bindings[:object].insight.post)
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
        field :is_active
      end

    end

  end
  
end
