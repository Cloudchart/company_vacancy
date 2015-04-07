module Admin::Feature
  extend ActiveSupport::Concern

  included do

    rails_admin do
      list do
        exclude_fields :uuid, :scope
      end
    end

  end
  
end
