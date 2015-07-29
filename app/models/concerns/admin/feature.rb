module Admin::Feature
  extend ActiveSupport::Concern

  included do

    rails_admin do
      list do
        sort_by :featurable_type

        field :scope
        field :effective_from
        field :effective_till

        field :assigned_title do
          label 'Title'

          pretty_value do
            feature = bindings[:object]

            url = if feature.url.present?
              feature.url
            else
              bindings[:view].main_app.send("#{feature.featurable_type.underscore}_path", feature.featurable)
            end

            bindings[:view].link_to feature.assigned_title, url
          end
        end

        field :featurable_type do
          label 'Type'
        end

        field :is_active
        field :position

        field :assigned_image, :dragonfly do
          label 'Image'
        end

        field :display_types do
          formatted_value do
            bindings[:object].display_types.to_sentence
          end
        end
      end

      edit do
        field :scope
        field :effective_from
        field :effective_till
        field :is_active
        field :position
        field :image

        field :display_types do
          partial :display_types
        end

        field :title
        field :url
      end

    end

  end
  
end
