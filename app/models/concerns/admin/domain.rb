module Admin::Domain
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        sort_by :created_at
        fields :name, :status, :created_at, :updated_at
      end

      edit do
        fields :name, :status
      end
    end
  end

end
