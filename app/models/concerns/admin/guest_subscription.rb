module Admin::GuestSubscription
  extend ActiveSupport::Concern

  included do

    rails_admin do
      object_label_method :email

      list do
        sort_by :created_at
        fields :email, :is_verified, :created_at, :updated_at
      end

      edit do
        fields :is_verified
      end
    end

  end  
end
