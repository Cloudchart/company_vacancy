class Page < ActiveRecord::Base
  include Uuidable
  include Sluggable
  include Admin::Page

  after_validation :generate_slug

  has_paper_trail

  validates :title, presence: true, uniqueness: true

private

  def generate_slug
    self.slug = title.parameterize
  end

end
