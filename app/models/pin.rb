class Pin < ActiveRecord::Base
  include Uuidable
  include Trackable
  include Featurable
  include Previewable
  include Admin::Pin

  acts_as_paranoid

  nilify_blanks only: [:content, :origin]

  has_should_markers :should_allow_domain_name

  before_save :skip_generate_preview!, unless: :insight?
  before_save :squish_origin, if: -> { origin_changed? && origin.present? }
  before_save :nullify_diffbot_response_owner, if: -> { origin_changed? && origin.blank? }
  before_save :crawl_origin
  after_save :check_domain_from_origin

  belongs_to :user
  belongs_to :parent, -> { with_deleted }, class_name: self.name, counter_cache: true
  belongs_to :pinboard
  belongs_to :pinnable, polymorphic: true
  belongs_to :post, foreign_key: :pinnable_id

  has_one :diffbot_response_owner, as: :owner, dependent: :destroy
  has_one :diffbot_response, through: :diffbot_response_owner, source: :owner, source_type: self.name

  has_many :children, class_name: self.name, foreign_key: :parent_id
  has_many :followers, as: :favoritable, dependent: :destroy, class_name: Favorite.name

  validates :content, presence: true, if: :should_validate_content_presence?
  validates :parent_id, uniqueness: { scope: :pinboard_id, conditions: -> { where(deleted_at: nil) } }, allow_blank: true, if: -> { is_suggestion? && pinboard_id }

  scope :insights, -> { where(parent: nil).where.not(content: nil) }

  def insight?
    parent_id.blank? && content.present?
  end

  def content
    is_suggestion? ? parent.content : read_attribute(:content)
  end

  def source_user_id
    parent ? parent.user_id : user_id
  end

  def should_validate_content_presence?
    parent.blank? || (@update_by.present? && user_id != @update_by.uuid && !is_suggestion?)
  end

  def update_by!(update_by)
    @update_by = update_by
  end

  def origin_uri
    uri = URI.parse(origin) rescue false
    uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS) ? uri : nil
  end

  def is_origin_domain_allowed
    insight = parent ? parent : self
    (uri = insight.origin_uri) && Domain.find_by(name: uri.host).try(:allowed?)
  end

private

  def squish_origin
    self.origin = origin.squish
  end

  def nullify_diffbot_response_owner
    self.diffbot_response_owner = nil
  end

  def crawl_origin
    if Cloudchart::Utils.should_perform_sidekiq_worker? && origin_changed? && origin.present? && origin_uri
      DiffbotWorker.perform_async(id, self.class.name, :origin, origin)
    end
  end

  def check_domain_from_origin
    if origin_changed? && origin.present? && (uri = origin_uri)
      domain = Domain.find_by(name: uri.host)
      unless domain
        status = should_allow_domain_name? ? :allowed : :pending
        Domain.create(name: uri.host, status: status)
      end
    end
  end

end
