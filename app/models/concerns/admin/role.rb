module Admin::Role
  extend ActiveSupport::Concern

  included do

    rails_admin do
      visible false
      object_label_method :value
    end

  end
  
end
