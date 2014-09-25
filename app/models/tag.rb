class Tag < ActiveRecord::Base
  include Uuidable

  before_save do
    self.name = name.parameterize
  end

  has_paper_trail
  has_many :taggings, dependent: :destroy

  validates :name, presence: true

  rails_admin do

    list do
      sort_by :taggings_count
      fields :name, :is_acceptable, :taggings_count

      field :taggings_count do
        sort_reverse true
      end
    end

    edit do
      include_fields :name, :is_acceptable
    end

  end

end
