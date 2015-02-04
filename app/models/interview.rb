class Interview < ActiveRecord::Base
  include Uuidable
  include Sluggable

  after_validation :generate_slug

  has_paper_trail

  validates :name, :company_name, presence: true

private

  def generate_slug
    self.slug = "#{name.parameterize}-#{rand(1000..9999)}" if name_changed?
  end

end
