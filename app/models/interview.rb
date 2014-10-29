class Interview < ActiveRecord::Base
  include Uuidable
  include Sluggable

  after_validation :generate_slug

  has_paper_trail

  validates :name, :company_name, presence: true

  rails_admin do
    list do
      exclude_fields :uuid, :email, :ref_email, :slug, :whosaid
      sort_by :created_at

      field :name do
        pretty_value { bindings[:view].mail_to bindings[:object].email, value }
      end

      field :ref_name do
        pretty_value { bindings[:view].mail_to bindings[:object].ref_email, value }
      end
    end

    edit do
      exclude_fields :uuid, :is_accepted, :slug
    end
  end

private

  def generate_slug
    self.slug = "#{name.parameterize}-#{rand(1000..9999)}" if name_changed?
  end

end
