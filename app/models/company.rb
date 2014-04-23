class Company < ActiveRecord::Base
  include Uuidable
  include Sectionable
  include Tire::Model::Search
  include Tire::Model::Callbacks  

  SECTIONS = %i(about product people vacancies contacts).inject({}) { |hash, val| hash.merge({ I18n.t("company.sections.#{val}") => val }) }
  BLOCK_TYPES = %i(paragraph block_image person vacancy).inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }

  has_and_belongs_to_many :industries
  has_one :logo, as: :owner, dependent: :destroy
  has_many :vacancies, dependent: :destroy
  has_many :people, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :activities, as: :source, dependent: :destroy
  # has_paper_trail

  accepts_nested_attributes_for :logo, allow_destroy: true

  validates :name, :country, :industry_ids, presence: true

  settings ElasticSearchNGramSettings do
    mapping do
      indexes :name, analyzer: 'ngram_analyzer'
    end
  end

  class << self
    def search(params)
      tire.search(load: true) do
        query { string "name:#{params[:query]}" } if params[:query].present?
      end
    end
  end

  def industry
    industries.first
  end

  def build_objects
    blocks.build(section: :about, position: 0, identity_type: 'Paragraph', is_locked: true)
    blocks.build(section: :product, position: 0, identity_type: 'Paragraph', is_locked: true)
    blocks.build(section: :product, position: 1, identity_type: 'BlockImage', is_locked: true)
    blocks.build(section: :people, position: 0, identity_type: 'Person', is_locked: true)
    blocks.build(section: :people, position: 1, identity_type: 'Paragraph', is_locked: true)
    blocks.build(section: :vacancies, position: 0, identity_type: 'Vacancy', is_locked: true)
  end

  def associate_with_person(user)
    email = user.emails.first.address
    name = user.try(:full_name).present? ? user.full_name : email.split('@')[0]
    people << user.people.build(name: name, email: email, phone: user.phone)
  end

end
