module Admin::Pinboard
  extend ActiveSupport::Concern

  included do

    rails_admin do
      list do
        sort_by :is_important
        fields :title, :user
        field :is_important do
          sort_reverse true
        end
        fields :created_at, :updated_at
      end

      edit do
        field :title do
          html_attributes do
            { autofocus: true }
          end
        end
      end
    end

  end
  
end
