module Admin::Page
  extend ActiveSupport::Concern

  included do

    rails_admin do
      field :title
      field :body, :wysihtml5 do
        config_options html: true
      end
    end

  end
  
end
