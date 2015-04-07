module Admin::Pinboard
  extend ActiveSupport::Concern

  included do

    rails_admin do
      list do
        sort_by :title
        fields :title, :user, :created_at, :updated_at
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
