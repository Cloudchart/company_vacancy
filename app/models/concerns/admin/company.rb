module Admin::Company
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        fields :name, :is_published, :created_at, :updated_at
      end
    end
  end
  
end
