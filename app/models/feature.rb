class Feature < ActiveRecord::Base
  include Uuidable
  include Admin::Feature

  DISPLAY_TYPES = [:blurred, :darkened]
  FEATURABLE_TYPES = %w(Company Pin Pinboard)

  before_save :assign_effective_till, if: -> { effective_from.present? && effective_till.blank? }

  enum scope: [:pending, :main, :feed]

  dragonfly_accessor :image

  nilify_blanks only: [:title, :category, :url, :effective_from, :effective_till]

  belongs_to :featurable, polymorphic: true

  validates :featurable, presence: true
  validates :featurable_type, inclusion: { in: FEATURABLE_TYPES }
  validates :url, url: true, allow_blank: true
  validates :effective_from, :effective_till, date: true, allow_blank: true

  scope :only_active, -> { where(is_active: true) }
  scope :with_display_type, -> type { where("display_types_mask & #{2**DISPLAY_TYPES.index(type)} > 0") }

  def display_types=(display_types)
    self.display_types_mask = (display_types.map(&:to_sym) & DISPLAY_TYPES).map { |r| 2**DISPLAY_TYPES.index(r) }.sum
  end
  
  def display_types
    DISPLAY_TYPES.reject { |r| ((display_types_mask || 0) & 2**DISPLAY_TYPES.index(r)).zero? }
  end

  def assigned_title
    title.present? ? title : featurable.try(:title) || featurable.try(:name) || featurable.try(:content)
  end

  def assigned_image
    image_stored? ? image : featurable.try(:preview)
  end

private

  def assign_effective_till
    self.effective_till = effective_from
  end

end
