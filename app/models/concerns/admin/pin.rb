module Admin::Pin
  extend ActiveSupport::Concern

  included do

    rails_admin do
      label 'Insight'
      label_plural 'Insights'
      object_label_method :content

      list do
        sort_by :user
        scopes [:insights]

        field :user do
          sort_reverse true
          searchable [:first_name, :last_name]
        end

        field :content
        field :is_approved
      end

      edit do
        field :is_featured, :boolean
        field :is_approved
      end
    end

  end
  
end
