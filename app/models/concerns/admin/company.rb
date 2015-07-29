module Admin::Company
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        fields :name, :is_published
        field :is_featured, :boolean
        fields :created_at, :updated_at
      end
    end
  end
  
end
