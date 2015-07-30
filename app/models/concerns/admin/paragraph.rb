module Admin::Paragraph
  extend ActiveSupport::Concern

  included do

    rails_admin do
      list do
        sort_by :created_at
        scopes [:plain]
        fields :content, :created_at, :updated_at
      end

      edit do
        field :content, :wysihtml5 do
          config_options html: true
        end
      end

    end

  end
  
end
