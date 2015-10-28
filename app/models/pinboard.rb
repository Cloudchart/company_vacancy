class Pinboard < ActiveRecord::Base
  include Uuidable
  include Previewable
  include Preloadable
  include Featurable
  include Followable
  include Taggable
  include Admin::Pinboard

  ACCESS_RIGHTS = [:public, :protected, :private].freeze
  ACCESS_ROLE = :reader

  after_validation :update_algolia_search_index, if: -> { persisted? && title_changed? }

  enum suggestion_rights: { anyone: 0, editors: 1 }

  belongs_to :user

  has_many :pins, dependent: :destroy
  has_many :roles, as: :owner, dependent: :destroy
  has_many :posts, through: :pins, source: :pinnable, source_type: 'Post'
  has_many :users, through: :roles
  has_many :tokens, as: :owner, dependent: :destroy
  has_many :tags, through: :taggings, after_add: :update_algolia_search_index, after_remove: :update_algolia_search_index

  validates :title, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :access_rights, presence: true, inclusion: { in: ACCESS_RIGHTS.map(&:to_s) }

  # Roles on Users
  #
  { readers: [:reader, :editor], writers: :editor }.each do |scope, role|
    has_many :"#{scope}_pinboards_roles", -> { where(value: role) }, as: :owner, class_name: 'Role'
    has_many :"#{scope}", through: :"#{scope}_pinboards_roles", source: :user
  end

  sifter :system do
    access_rights.eq('public') & user_id.eq(nil)
  end

  sifter :available_through_roles do |user, values|
    access_rights.not_eq('public') &
    roles.user_id.eq(user.id) &
    roles.value.in(values)
  end

  scope :_featured, -> (s) { joins(:features).where(features: { scope: Feature.scopes[s.to_sym] }) }
  scope :_super_feature, -> (s) { _featured(s).where(features: { position: -1 }) }
  scope :_common_feature, -> (s) { _featured(s).where.not(features: { position: -1 }) }

  scope :available, -> { where(access_rights: :public) }

  scope :system, -> do
    where access_rights: :public, user_id: nil
  end

  scope :readable, -> do
    joins { roles.outer }.where { roles.value.eq('reader') }
  end

  scope :writable, -> do
    joins { roles.outer }.where { roles.value.eq('editor') }
  end

  scope :ready_for_broadcast, -> (user, start_time, end_time) do
    where {
      created_at.gteq(start_time) &
      created_at.lteq(end_time) &
      user_id.in(user.users_favorites.map(&:favoritable_id))
    }
  end

  def invite_tokens
    tokens.select { |token| token.name == 'invite' }
  end

  def public?
    access_rights == 'public'
  end

  def protected?
    access_rights == 'protected'
  end

  def editorial?
    user.try(:editor?)
  end

  def update_algolia_search_index(tag=nil)
    return if Rails.env.development?
    AlgoliaSearchWorker.perform_async(id, 'Pinboard', false, only_dependencies: true)
  end

end
