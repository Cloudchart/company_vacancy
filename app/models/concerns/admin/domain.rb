module Admin::Domain
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        sort_by :created_at
        fields :name, :status, :diffbot_api, :created_at, :updated_at
      end

      edit do
        fields :name, :status, :diffbot_api
      end
    end
  end

end
