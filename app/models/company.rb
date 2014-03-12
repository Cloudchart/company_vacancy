class Company < ActiveRecord::Base
  include Uuidable
  include Sectionable

  SECTIONS = %i(about product people vacancies contacts).inject({}) { |hash, val| hash.merge({ I18n.t("company.sections.#{val}") => val }) }
  BLOCK_TYPES = %i(paragraph block_image person vacancy).inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }

  has_many :vacancies, dependent: :destroy
  has_many :people, dependent: :destroy
  has_one :logo, as: :owner, dependent: :destroy

  accepts_nested_attributes_for :logo, allow_destroy: true

  validates :name, presence: true

  def save_with_buildings(user)
    person = people.build(name: user.name, email: user.email, phone: user.phone)
    person.user = user

    blocks.build(section: :about, position: 0, identity_type: 'Paragraph', is_locked: true)
    blocks.build(section: :product, position: 0, identity_type: 'Paragraph', is_locked: true)
    blocks.build(section: :product, position: 1, identity_type: 'BlockImage', is_locked: true)
    blocks.build(section: :people, position: 0, identity_type: 'Person', is_locked: true)
    blocks.build(section: :people, position: 1, identity_type: 'Paragraph', is_locked: true)
    blocks.build(section: :vacancies, position: 0, identity_type: 'Vacancy', is_locked: true)
    
    save
  end

end
