class Feature < ActiveRecord::Base
  include Uuidable
  include Urlable
  include Admin::Feature

  DISPLAY_TYPES = [:blurred, :darkened]

  before_create do
    self.featurable_type ||= 'Pin'
  end

  dragonfly_accessor :image

  # belongs_to :featurable, polymorphic: true
  belongs_to :insight, class_name: 'Pin', foreign_key: :featurable_id, inverse_of: :features

  validates :insight, presence: true

  scope :insights, -> { where(featurable_type: 'Pin') }
  scope :only_active, -> { where(is_active: true) }
  scope :with_display_type, -> type { where("display_types_mask & #{2**DISPLAY_TYPES.index(type)} > 0") }

  def display_types=(display_types)
    self.display_types_mask = (display_types.map(&:to_sym) & DISPLAY_TYPES).map { |r| 2**DISPLAY_TYPES.index(r) }.sum
  end
  
  def display_types
    DISPLAY_TYPES.reject { |r| ((display_types_mask || 0) & 2**DISPLAY_TYPES.index(r)).zero? }
  end

  def assigned_image
    image_stored? ? image : insight.post.pictures.first.try(:image)
  end

  def assigned_title
    title.present? ? title : insight.post.title
  end

end
