module Admin::Company
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        sort_by :is_important
        fields :name, :is_published
        field :is_important do
          sort_reverse true
        end
        fields :created_at, :updated_at
      end
    end
  end
  
end
