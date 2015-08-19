module Admin::Pinboard
  extend ActiveSupport::Concern

  included do

    rails_admin do
      list do
        sort_by :created_at
        field :title

        field :user do
          searchable [:first_name, :last_name]
        end

        field :is_featured, :boolean
        fields :created_at, :updated_at
      end

      edit do
        field :title do
          visible do
            bindings[:object].user_id.blank?
          end

          html_attributes do
            { autofocus: true }
          end
        end

        field :is_featured, :boolean
        field :tags
      end
    end

  end
  
end
