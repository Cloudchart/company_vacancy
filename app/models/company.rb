class Company < ActiveRecord::Base
  include Uuidable

  SECTIONS = %i(about product people vacancies contacts).inject({}) { |hash, val| hash.merge({ I18n.t("company.sections.#{val}") => val }) }

  after_validation :build_sections_and_locked_blocks
  before_destroy :mark_for_destruction

  serialize :sections, OpenStruct

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

private

  def build_sections_and_locked_blocks
    SECTIONS.values.each { |section| sections.send("#{section}=", nil) }
    blocks.build(section: :about, position: 0, identity_type: 'Paragraph', locked: true)
    blocks.build(section: :product, position: 0, identity_type: 'Paragraph', locked: true)
    blocks.build(section: :product, position: 1, identity_type: 'BlockImage', locked: true)
    blocks.build(section: :people, position: 0, identity_type: 'Person', locked: true)
    blocks.build(section: :people, position: 1, identity_type: 'Paragraph', locked: true)
    blocks.build(section: :vacancies, position: 0, identity_type: 'Vacancy', locked: true)
  end

end
