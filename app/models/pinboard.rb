class Pinboard < ActiveRecord::Base
  include Uuidable
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include Admin::Pinboard

  ACCESS_RIGHTS = [:public, :protected, :private].freeze
  INVITABLE_ROLES = [:editor, :reader].freeze

  validates :title, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :access_rights, presence: true, inclusion: { in: ACCESS_RIGHTS.map(&:to_s) }

  belongs_to :user

  has_many :pins
  has_many :roles, as: :owner
  has_many :posts, through: :pins, source: :pinnable, source_type: 'Post'
  has_many :users, through: :roles
  has_many :tokens, as: :owner, dependent: :destroy
  has_many :followers, as: :favoritable, dependent: :destroy, class_name: 'Favorite'

  # Roles on Users
  #
  { readers: [:reader, :editor], writers: :editor }.each do |scope, role|
    has_many :"#{scope}_pinboards_roles", -> { where(value: role) }, as: :owner, class_name: Role
    has_many :"#{scope}", through: :"#{scope}_pinboards_roles", source: :user
  end

  settings ElasticSearchNGramSettings do
    mapping do
      indexes :title, type: 'string', analyzer: 'ngram_analyzer'
      indexes :description, type: 'string', analyzer: 'ngram_analyzer'
    end
  end

  class << self
    def search(params)
      # TODO: get rid of load option (store everything in elascitsearch)
      tire.search(load: true) do
        if params[:query].present?
          query do
            boolean do
              should { string Cloudchart::Utils.tokenized_query_string(params[:query], [:title, :description]) }
            end
          end
        end

        sort { by :title } if params[:query].blank?
        size 50
      end
    end
    
  end # of class methods

  sifter :system do
    access_rights.eq('public') & user_id.eq(nil)
  end

  sifter :available_through_roles do |user, values|
    access_rights.not_eq('public') &
    roles.user_id.eq(user.id) &
    roles.value.in(values)
  end

  scope :system, -> do
    where access_rights: :public, user_id: nil
  end

  scope :readable, -> do
    joins { roles.outer }.where { roles.value.eq('reader') }
  end

  scope :writable, -> do
    joins { roles.outer }.where { roles.value.eq('editor') }
  end

  def invite_tokens
    tokens.where(name: :invite)
  end

end
