class Page < ActiveRecord::Base
  include Uuidable
  include Sluggable

  after_validation :generate_slug

  has_paper_trail

  validates :title, presence: true, uniqueness: true

  rails_admin do
    field :title
    field :body, :wysihtml5 do
      config_options html: true
    end
  end

private

  def generate_slug
    self.slug = title.parameterize
  end

end
