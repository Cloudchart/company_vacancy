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
  has_many :subscriptions, as: :subscribable, dependent: :destroy
  # has_paper_trail
  
  # Charts
  #
  has_many :charts, class_name: CloudBlueprint::Chart.name, dependent: :destroy

  accepts_nested_attributes_for :logo, allow_destroy: true

  validates :name, :country, :industry_ids, presence: true, on: :update
  
  settings ElasticSearchNGramSettings do
    mapping do
      indexes :name, analyzer: 'ngram_analyzer'
    end
  end

  def owner
    people.find_by(is_company_owner: true).user
  end

  class << self
    def search(params)
      tire.search(load: true) do
        query { string "name:#{params[:query]}" } if params[:query].present?
      end
    end
  end

  def find_or_create_placeholder_for(user)
    company = user.companies.find_by(is_empty: true) || begin
      company = Company.new(is_empty: true)
      company.associate_with_person(user)
      company.should_build_objects!
      company.save!
      company
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
    people << user.people.build(
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.emails.first.address,
      phone: user.phone,
      is_company_owner: true
    )
  end

end
