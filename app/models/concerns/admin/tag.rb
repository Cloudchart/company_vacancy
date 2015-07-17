module Admin::Tag
  extend ActiveSupport::Concern

  included do

    rails_admin do
      list do
        sort_by :taggings_count
        fields :name, :is_acceptable, :taggings_count, :created_at

        field :taggings_count do
          sort_reverse true
        end
      end

      edit do
        fields :name, :is_acceptable

        field :name do
          html_attributes do
            { autofocus: true }
          end
        end

        field :is_acceptable do
          html_attributes do
            { checked:  bindings[:object].new_record? ? 'checked' : bindings[:object].is_acceptable }
          end

          default_value do
            '1' if bindings[:object].new_record?
          end
        end
      end
    end

  end
  
end
