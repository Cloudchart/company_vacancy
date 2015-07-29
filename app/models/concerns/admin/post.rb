module Admin::Post
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        fields :title, :owner
        field :is_featured, :boolean
        fields :created_at, :updated_at
      end
    end
  end
  
end
