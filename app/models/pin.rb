class Pin < ActiveRecord::Base
  include Uuidable
  include Trackable
  include Featurable
  include Followable
  include Previewable
  include Taggable
  include Admin::Pin
  include Search::Pin
  include Preload::Pin

  acts_as_paranoid

  nilify_blanks only: [:content, :origin]

  has_should_markers :should_allow_domain_name

  before_save :skip_generate_preview!, unless: :insight?
  before_save :use_post_url_for_origin, :squish_origin, :nullify_diffbot_response_owner

  after_save :check_domain_from_origin

  belongs_to :user
  belongs_to :parent, -> { with_deleted }, class_name: self.name, counter_cache: true
  belongs_to :pinboard
  belongs_to :pinnable, polymorphic: true
  belongs_to :post, foreign_key: :pinnable_id

  has_one :diffbot_response_owner, as: :owner, dependent: :destroy
  has_one :diffbot_response, through: :diffbot_response_owner

  has_many :children, class_name: self.name, foreign_key: :parent_id
  has_many :favorites, as: :favoritable
  has_many :reflections, -> { where(kind: 'reflection') }, class_name: self.name, foreign_key: :parent_id

  has_many  :votes, as: :destination
  has_many  :users_votes, -> { where(source_type: User.name) }, as: :destination, class_name: Vote.name

  validates :content, presence: true, if: :should_validate_content_presence?
  validates :parent_id, uniqueness: { scope: :pinboard_id, conditions: -> { where(deleted_at: nil) } }, allow_blank: true, if: -> { is_suggestion? && pinboard_id }

  scope :insights, -> { where(parent: nil).where.not(content: nil) }
  scope :reflection,  -> { where(kind: 'reflection') }

  class << self

    def ready_for_broadcast(user, start_time, end_time)
      favorite_user_ids = user.users_favorites.map(&:favoritable_id)
      favorite_pinboard_ids = user.pinboards_favorites.map(&:favoritable_id)

      insights.where {
        created_at.gteq(start_time) &
        created_at.lteq(end_time) & (
          user_id.in(favorite_user_ids) |
          pinboard_id.in(favorite_pinboard_ids)
        )
      }
    end

  end

  # Favorites / Reflection
  #
  def reflection_timeout_for(user)
    user.editor? ? 1.second.ago : 7.days.ago
  end

  def should_show_reflection_for_user?(user)
    favorite    = favorites.find { |f| f.user_id == user.id }
    reflection  = reflections.find { |r| r.user_id == user.id }
    reflection.nil? && favorite.present? && favorite.created_at < reflection_timeout_for(user)
  end

  def insight?
    parent_id.blank? && content.present?
  end

  def reflection?
    kind == 'reflection'
  end

  def content
    is_suggestion? ? parent.content : read_attribute(:content)
  end

  def source(value)
    parent ? parent.send(value) : self.send(value)
  end

  def should_validate_content_presence?
    parent.blank? || (kind == 'reflection' && is_approved) || (@update_by.present? && user_id != @update_by.uuid && !is_suggestion?)
  end

  def update_by!(update_by)
    @update_by = update_by
  end

  def origin_uri
    uri = URI.parse(origin) rescue false
    uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS) ? uri : nil
  end

  def is_origin_domain_allowed
    insight = case
    when kind == 'reflection'
      self
    when parent
      parent
    else
      self
    end
    (uri = insight.origin_uri) && Domain.find_by(name: uri.host).try(:allowed?)
  end

private

  def use_post_url_for_origin
    if origin.blank? && pinnable_type == 'Post'
      self.origin = Rails.application.routes.url_helpers.post_url(pinnable)
    end
  end

  def squish_origin
    self.origin = origin.squish if origin_changed? && origin.present?
  end

  def nullify_diffbot_response_owner
    self.diffbot_response_owner = nil if origin_changed?
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
