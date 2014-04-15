class Vacancy < ActiveRecord::Base
  include Uuidable
  include Sectionable

  SECTIONS = %i(settings vacancy requirements benefits).inject({}) { |hash, val| hash.merge({ I18n.t("vacancy.sections.#{val}") => val }) }
  BLOCK_TYPES = %i(paragraph block_image).inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }
  
  is_impressionable counter_cache: true, unique: true

  serialize :settings, VacancySetting

  belongs_to :company
  # has_paper_trail

  validates :name, presence: true
  validate :validity_of_settings

  def settings=(hash)
    settings.attributes = hash
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
