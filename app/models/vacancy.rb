class Vacancy < ActiveRecord::Base
  include Uuidable

  serialize :settings, VacancySetting

  SECTIONS = %i(settings vacancy requirements benefits).inject({}) { |hash, val| hash.merge({ I18n.t("vacancy.sections.#{val}") => val }) }
  BLOCK_TYPES = %i(paragraph block_image).inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }

  belongs_to :company

  validates :name, presence: true
  validate :validity_of_settings

  def settings=(hash)
    settings.attributes = hash
  end

private

  def validity_of_settings
    errors.add(:settings, settings.errors) unless settings.valid?
  end

end
