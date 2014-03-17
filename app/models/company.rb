class Company < ActiveRecord::Base
  include Uuidable
  include Sectionable

  SECTIONS = %i(about product people vacancies contacts).inject({}) { |hash, val| hash.merge({ I18n.t("company.sections.#{val}") => val }) }
  BLOCK_TYPES = %i(paragraph block_image person vacancy).inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }

  after_validation :build_objects, if: :should_build_objects?

  has_one :logo, as: :owner, dependent: :destroy
  has_many :vacancies, dependent: :destroy
  has_many :people, dependent: :destroy
  has_many :events, dependent: :destroy

  accepts_nested_attributes_for :logo, allow_destroy: true

  validates :name, presence: true

  def build_objects
    blocks.build(section: :about, position: 0, identity_type: 'Paragraph', is_locked: true)
    blocks.build(section: :product, position: 0, identity_type: 'Paragraph', is_locked: true)
    blocks.build(section: :product, position: 1, identity_type: 'BlockImage', is_locked: true)
    blocks.build(section: :people, position: 0, identity_type: 'Person', is_locked: true)
    blocks.build(section: :people, position: 1, identity_type: 'Paragraph', is_locked: true)
    blocks.build(section: :vacancies, position: 0, identity_type: 'Vacancy', is_locked: true)
  end

end
