class Vacancy < ActiveRecord::Base
  include Uuidable
  include Sectionable
  include Trackable

  SECTIONS = %i(settings vacancy requirements benefits).inject({}) { |hash, val| hash.merge({ I18n.t("vacancy.sections.#{val}") => val }) }
  BLOCK_TYPES = %i(paragraph block_image).inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }
  
  is_impressionable counter_cache: true, unique: true

  serialize :settings, VacancySetting

  scope :later_then, -> (date) { where arel_table[:updated_at].gteq(date) }

  belongs_to :company
  belongs_to :author, class_name: User
  has_many :responses, class_name: VacancyResponse
  has_many :responded_users, through: :responses, source: :user
  # has_paper_trail

  validates :name, presence: true
  #validate :validity_of_settings

  def settings=(hash)
    settings.attributes = hash
  end

  def as_json_for_chart
    as_json(only: [:uuid, :name, :description])
  end

private

  def validity_of_settings
    errors.add(:settings, settings.errors) unless settings.valid?
  end

  def build_objects
    blocks.build(section: :requirements, position: 0, identity_type: 'Paragraph', is_locked: true)
    blocks.build(section: :benefits, position: 0, identity_type: 'Paragraph', is_locked: true)
  end  

end
