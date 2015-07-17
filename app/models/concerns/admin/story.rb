module Admin::Story
  extend ActiveSupport::Concern

  included do

    rails_admin do
      list do
        sort_by :posts_stories_count
        fields :name, :company, :posts_stories_count, :created_at

        field :posts_stories_count do
          sort_reverse true
        end
      end

      edit do
        fields :name

        field :name do
          html_attributes do
            { autofocus: true }
          end
        end
      end
    end

  end
  
end
