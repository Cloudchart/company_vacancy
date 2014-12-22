class Story < ActiveRecord::Base
  include Uuidable

  before_save do
    self.name = name.gsub(/[^A-Za-z0-9\-_|\s]+/i, '').squish.gsub(/\s/, '_')
  end

  belongs_to :company

  has_paper_trail
  has_many :posts_stories, dependent: :delete_all
  has_many :posts, through: :posts_stories

  validates :name, presence: true
  validates :name, uniqueness: { scope: :company_id, case_sensitive: false }

  rails_admin do

    list do
      sort_by :posts_stories_count
      fields :name, :posts_stories_count, :created_at

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
