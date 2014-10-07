class Company < ActiveRecord::Base
  include Uuidable
  include Sectionable
  include Sluggable
  include Taggable
  include Tire::Model::Search
  include Tire::Model::Callbacks  

  BlockTypes  = ['Paragraph', 'BlockImage', 'Person', 'Vacancy']
  Sections    = ['About', 'Product', 'People', 'Vacancies']
  
  INVITABLE_ROLES = [:editor, :trusted_reader, :public_reader].freeze
  ROLES           = ([:owner] + INVITABLE_ROLES).freeze

  dragonfly_accessor :logotype

  # deprecated
  # has_one :logo, as: :owner, dependent: :destroy
  # accepts_nested_attributes_for :logo, allow_destroy: true

  has_and_belongs_to_many :banned_users, class_name: 'User', join_table: 'companies_banned_users'

  has_many :vacancies, dependent: :destroy
  has_many :people, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :activities, as: :trackable, dependent: :destroy
  has_many :nested_activities, class_name: 'Activity', as: :source, dependent: :destroy
  has_many :subscriptions, as: :subscribable, dependent: :destroy
  has_many :charts, class_name: 'CloudBlueprint::Chart', dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy
  has_many :tokens, as: :owner, dependent: :destroy
  has_many :roles, as: :owner, dependent: :destroy
  has_many :users, through: :roles
  # has_paper_trail

  # validates :name, presence: true, on: :update
  validates :site_url, url: true, allow_blank: true
  validate  :publish_check, if: 'is_published && is_published_changed?'

  settings ElasticSearchNGramSettings do
    mapping do
      indexes :name, analyzer: 'ngram_analyzer'
      indexes :is_published, type: 'boolean'
      indexes :tags do
        indexes :name, analyzer: 'ngram_analyzer'
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
              should { string Cloudchart::Utils.tokenized_query_string(params[:query], ['name', 'tags.name'], 'OR') }
            end
          end
        end

        sort { by :name } if params[:query].blank?
        filter :term, is_published: true

      end
    end
    
  end # of class methods

  def to_indexed_json
    to_json(
      include: { tags: { only: [:name] } }
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
    roles.find_by(value: :owner).user
  end

  # temporary has_one simulation
  def chart
    charts.order(:created_at).first
  end
  
  def pictures
    blocks.select { |b| b.identity_type == 'Picture' }.map(&:picture).compact
  end
  
  def paragraphs
    blocks.select { |b| b.identity_type == 'Paragraph' }.map(&:paragraph).compact
  end

  def invite_tokens
    tokens.where(name: :invite)
  end

  def build_objects
    blocks.build(position: 0, identity_type: 'Person', is_locked: true)
    blocks.build(position: 1, identity_type: 'Paragraph', is_locked: true)
    blocks.build(position: 2, identity_type: 'Vacancy', is_locked: true)
    blocks.build(position: 3, identity_type: 'Picture', is_locked: true)
    charts.build(title: 'Default Chart')
  end
  
  def as_json_for_editor
    as_json(only: [:uuid], methods: :sections_titles)
  end

private

  def publish_check
    unless name.present? && logotype.present? && people.any? && tags.any? && charts.first.try(:nodes).try(:any?)
      errors.add(:is_published, I18n.t('errors.messages.company_can_not_become_published'))
    end
  end

end
