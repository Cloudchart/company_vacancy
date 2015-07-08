class Company < ActiveRecord::Base
  include Uuidable
  include Blockable
  include Sluggable
  include Taggable
  include Preloadable
  include Previewable
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include Admin::Company

  INVITABLE_ROLES   = [:editor, :trusted_reader, :public_reader].freeze
  ROLES             = ([:owner] + INVITABLE_ROLES).freeze
  ACCESS_ROLE       = :public_reader

  after_save do
    update(is_name_in_logo: false) if logotype.blank? && is_name_in_logo?
  end

  dragonfly_accessor :logotype

  belongs_to :user

  has_and_belongs_to_many :banned_users, class_name: 'User', join_table: 'companies_banned_users'

  has_many :vacancies, dependent: :destroy
  has_many :people, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :activities, as: :trackable, dependent: :destroy
  has_many :nested_activities, class_name: 'Activity', as: :source, dependent: :destroy
  has_many :subscriptions, as: :subscribable, dependent: :destroy
  has_many :followers, as: :favoritable, dependent: :destroy, class_name: 'Favorite'
  has_many :tokens, as: :owner, dependent: :destroy
  has_many :roles, as: :owner, dependent: :destroy
  has_many :users, through: :roles
  has_many :posts, as: :owner, dependent: :destroy
  has_many :stories, dependent: :destroy

  validates :site_url, domain: true, allow_blank: true
  validate  :publish_check, if: 'is_published? && is_published_changed?'

  scope :important, -> { where(is_important: true) }
  scope :published, -> { where(is_published: true) }

  settings ElasticSearchNGramSettings do
    mapping do
      indexes :name, type: 'string', analyzer: 'ngram_analyzer'
      indexes :is_published, type: 'boolean'
      indexes :tags do
        indexes :name, type: 'string', analyzer: 'ngram_analyzer'
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
        size 50
      end
    end

  end # of class methods


  # Insights
  #

  acts_as_preloadable :insights, posts: { pins: :parent } # preload parent because of suggestions. TODO: change this in future versions

  def insights
    posts.map(&:pins).flatten.select { |p| p.content.present? && p.parent_id.blank? }
  end

  #
  # / Insights


  # People
  #

  acts_as_preloadable :staff, blocks: :people

  def staff
    blocks.map(&:people).flatten.compact.uniq
  end

  #
  # / People


  def to_indexed_json
    to_json(
      include: { tags: { only: [:name] } }
    )
  end

  def public_posts
    Post.only_public.where(owner_id: id, owner_type: 'Company')
  end

  def humanized_id
    Cloudchart::RFC1751.encode(id).downcase.gsub(/\s/, '-')
  end

  def formatted_site_url
    site_url.match(/http:\/\/|https:\/\//) ? site_url : "http://#{site_url}"
  end

  def owner
    roles.find_by(value: :owner).user
  end

  def invite_tokens
    tokens.where(name: :invite)
  end

  def build_objects
    blocks.build(position: 0, identity_type: 'Person', is_locked: true)
    blocks.build(position: 1, identity_type: 'Paragraph', is_locked: true)
    blocks.build(position: 3, identity_type: 'Picture', is_locked: true)
  end

private

  def publish_check
    unless name.present? && logotype.present? && people.any? && tags.any?
      errors.add(:is_published, I18n.t('errors.messages.company_can_not_become_published'))
    end
  end

end
