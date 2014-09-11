class Page < ActiveRecord::Base
  include Uuidable
  include Sluggable

  before_validation :build_slug

  has_paper_trail

  validates :title, presence: true, uniqueness: true

  rails_admin do
    field :title
    field :body, :wysihtml5 do
      config_options html: true
    end
  end

private

  def build_slug
    self.slug = title.downcase.squish.gsub(/\s/, '-')
  end

end
