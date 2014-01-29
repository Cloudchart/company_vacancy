class Vacancy < ActiveRecord::Base
  include Uuidable

  SECTIONS = %i(settings vacancy requirements benefits).inject({}) { |hash, val| hash.merge({ I18n.t("vacancy.sections.#{val}") => val }) }

  belongs_to :company

  validates :name, presence: true

end
