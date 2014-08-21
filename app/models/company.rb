class Company < ActiveRecord::Base
  include Uuidable
  include Sectionable
  include Tire::Model::Search
  include Tire::Model::Callbacks  

  # -- deprecated
  SECTIONS = %i(about product people vacancies contacts).inject({}) { |hash, val| hash.merge({ I18n.t("company.sections.#{val}") => val }) }
  BLOCK_TYPES = %i(paragraph block_image person vacancy).inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }
  # --

  BlockTypes  = ['Paragraph', 'BlockImage', 'Person', 'Vacancy']
  Sections    = ['About', 'Product', 'People', 'Vacancies']

  dragonfly_accessor :logotype

  has_and_belongs_to_many :industries
  has_and_belongs_to_many :banned_users, class_name: 'User', join_table: 'companies_banned_users'

  # -- deprecated
  has_one :logo, as: :owner, dependent: :destroy
  # --
  has_many :vacancies, dependent: :destroy
  has_many :people, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :activities, as: :trackable, dependent: :destroy
  has_many :nested_activities, class_name: 'Activity', as: :source, dependent: :destroy
  has_many :subscriptions, as: :subscribable, dependent: :destroy
  has_many :charts, class_name: 'CloudBlueprint::Chart', dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy
  has_many :tokens, as: :owner, dependent: :destroy
  # has_paper_trail

  accepts_nested_attributes_for :logo, allow_destroy: true

  # validates :name, :country, :industry_ids, presence: true, on: :update
  validates :short_name, uniqueness: true, allow_blank: true
  validates :site_url, url: true, allow_blank: true

  settings ElasticSearchNGramSettings do
    mapping do
      indexes :name, analyzer: 'ngram_analyzer'
      indexes :country_name, analyzer: 'snowball'
      indexes :is_listed, type: 'boolean'
      indexes :industries do
        indexes :name, analyzer: 'snowball'
      end
    end
  end

  class << self
    def search(params)
      # TODO: get rid of load option (store everything in elascitsearch)
      tire.search(load: true) do
        if params[:query].present?
          query do
            boolean do
              should { string Cloudchart::Utils.tokenized_query_string(params[:query], :name) }
              should { string Cloudchart::Utils.tokenized_query_string(params[:query], ['industries.name', 'country_name']) }
            end
          end

          facet 'countries' do
            query { string Cloudchart::Utils.tokenized_query_string(params[:query], :country_name, ' OR ') }
          end

          facet 'industries' do
            query { string Cloudchart::Utils.tokenized_query_string(params[:query], 'industries.name', ' OR ') }
          end
        end

        sort { by :name } if params[:query].blank?
        filter :term, is_listed: true

      end
    end

    def find(*args)
      return super if Cloudchart::Utils.is_uuid?(args.first)
      find_by(short_name: args.first) || super
    end
    
  end # of class methods

  def to_param
    short_name.present? ? short_name : super
  end

  def to_indexed_json
    to_json(
      include: { industries: { only: [:name] } }, 
      methods: [:country_name]
    )
  end

  def humanized_id
    Cloudchart::RFC1751.encode(id).downcase.gsub(/\s/, '-')
  end

  def formatted_site_url
    if site_url.match(/http:\/\/|https:\/\//)
      site_url
    else
      'http://' + site_url
    end
  end

  def owner
    people.find_by(is_company_owner: true).user
  end  

  def industry
    industries.first
  end
  
  def industry=(industry_id)
    self.industry_ids = [industry_id]
  end

  def country_name
    iso_country = ISO3166::Country[country]

    if iso_country
      iso_country.translations[I18n.locale.to_s] || iso_country.name
    else
      nil
    end
  end

  def build_objects
    blocks.build(section: :about,       position: 0, identity_type: 'Paragraph',  is_locked: true)
    blocks.build(section: :product,     position: 0, identity_type: 'Paragraph',  is_locked: true)
    blocks.build(section: :product,     position: 1, identity_type: 'BlockImage', is_locked: true)
    blocks.build(section: :people,      position: 0, identity_type: 'Person',     is_locked: true)
    blocks.build(section: :people,      position: 1, identity_type: 'Paragraph',  is_locked: true)
    blocks.build(section: :vacancies,   position: 0, identity_type: 'Vacancy',    is_locked: true)
    charts.build(title: 'Default Chart')
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
  
  def as_json_for_editor
    as_json(only: [:uuid], methods: :sections_titles)
  end

end
