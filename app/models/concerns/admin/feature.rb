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
              case feature.featurable_type
              when 'Pin'
                bindings[:view].main_app.insight_path(feature.featurable)
              when 'Pinboard'
                bindings[:view].main_app.collection_path(feature.featurable)
              when 'Company'
                bindings[:view].main_app.company_path(feature.featurable)
              end
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
        field :title
        field :url
        field :image

        field :display_types do
          partial :display_types
        end
      end

    end

  end
  
end
