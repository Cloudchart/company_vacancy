class Company < ActiveRecord::Base
  include Uuidable

  SECTIONS = %i(about product people vacancies contacts).inject({}) { |hash, val| hash.merge({ I18n.t("company.sections.#{val}") => val }) }

  has_many :blocks, -> { order(:section, :position) }, as: :owner, dependent: :destroy, inverse_of: :owner
  has_many :vacancies, dependent: :destroy
  has_many :people, dependent: :destroy
  has_one :logo, as: :owner, dependent: :destroy

  accepts_nested_attributes_for :logo, allow_destroy: true

  validates :name, presence: true
  
  def blocks_by_section(section)
    section = section.to_s
    blocks.select { |b| b.section == section }
  end

end
