class User < ActiveRecord::Base
  include Uuidable
  include Fullnameable
  include FriendlyId
  include Preloadable
  include Admin::User

  attr_accessor :current_password
  attr_reader :should_create_tour_tokens # needed for rails_admin
  attr_reader :invite

  # before_validation :build_blank_emails, unless: -> { emails.any? }
  before_validation :generate_password, if: -> { password.blank? }
  before_validation :extract_twitter, if: -> { twitter_changed? && twitter.present? }
  before_save :nillify_last_sign_in_at, if: :twitter_changed?
  before_save :nillify_slug, if: -> { twitter_changed? && twitter.blank? }
  before_destroy :mark_emails_for_destruction
  after_create :create_tour_tokens, if: :should_create_tour_tokens?
  after_create :create_unicorn_role, if: :should_create_unicorn_role?

  nilify_blanks only: [:twitter, :authorized_at]

  friendly_id :twitter, use: :slugged

  dragonfly_accessor :avatar

  has_should_markers(
    :should_validate_invite,
    :should_validate_name,
    :should_create_tour_tokens,
    :should_validate_twitter_handle_for_invite,
    :should_create_unicorn_role
  )

  has_secure_password

  has_and_belongs_to_many :friends

  has_many :emails, -> { order(:address) }, dependent: :destroy
  has_many :social_networks, inverse_of: :user, class_name: 'CloudProfile::SocialNetwork', dependent: :destroy
  has_many :oauth_providers, dependent: :destroy
  has_many :tokens, as: :owner, dependent: :destroy
  has_many :tokens_as_target, as: :target, class_name: 'Token', dependent: :destroy
  has_many :votes, as: :source
  has_many :activities, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :vacancies, foreign_key: :author_id
  has_many :vacancy_responses
  has_many :favorites, dependent: :destroy
  has_many :followers, as: :favoritable, dependent: :destroy, class_name: 'Favorite'
  has_many :roles, dependent: :destroy
  has_many :companies_roles, -> { where(owner_type: Company.name) }, class_name: Role.name
  has_one  :unicorn_role, -> { where(value: 'unicorn') }, class_name: 'Role', dependent: :destroy
  has_many :system_roles, -> { where(owner: nil) }, class_name: 'Role', dependent: :destroy
  has_many :people, dependent: :destroy
  has_many :pinboards, dependent: :destroy
  has_many :pins, dependent: :destroy
  has_many :companies, through: :roles, source: :owner, source_type: 'Company'
  has_many :landings, dependent: :destroy

  # Roles on Pinboards
  #
  { readable: [:reader, :editor], writable: :editor, followable: :follower }.each do |scope, role|
    has_many :"#{scope}_pinboards_roles", -> { where(value: role) }, class_name: Role
    has_many :"#{scope}_pinboards", through: :"#{scope}_pinboards_roles", source: :owner, source_type: Pinboard
  end

  validates :full_name, presence: true, if: :should_validate_name?
  validates :invite, presence: true, if: :should_validate_invite?
  validates :twitter, twitter_handle: true, uniqueness: { case_sensitive: false }, allow_blank: true

  # Companies
  #

  acts_as_preloadable :companies_through_roles, companies_roles: :company

  def companies_through_roles(scope = {})
    ability = Ability.new(scope[:current_user] || self)
    companies_roles.map(&:company).select { |c| ability.can?(:read, c) }
  end

  #
  # /Companies

  validate :validate_twitter_handle_for_invite, if: :should_validate_twitter_handle_for_invite?
  # validate :validate_email, on: :create

  scope :unicorns, -> { joins(:system_roles).where(roles: { value: 'unicorn'}) }
  scope :available_for_merge, -> user {
    where.not(uuid: user.id, authorized_at: nil)
    .where(twitter: nil, first_name: user.first_name, last_name: user.last_name)
  }

  class << self
    def create_with_twitter_omniauth_hash(hash)
      avatar_url = hash.info.image.present? ? hash.info.image.sub('_normal', '') : nil

      user = new(
        full_name:    hash.info.name,
        twitter:      hash.info.nickname,
        avatar_url:   avatar_url
      )

      user.should_create_tour_tokens!
      user.save!
      user
    end

    def find_by_email(email)
      Email.includes(:user).find_by(address: email).user rescue nil
    end
  end # of class methods

  def update_with_twitter_omniauth_hash(hash)
    # TODO: share this line with self.create_with_twitter_omniauth_hash
    avatar_url = hash.info.image.present? ? hash.info.image.sub('_normal', '') : nil

    update(full_name: hash.info.name, avatar_url: avatar_url)
  end

  def insight_features
    Feature.insights.only_active
  end

  def top_insights
    Pin.insights.includes(post: :company)
      .where('companies.is_published = ?', true)
      .references(:company)
      .order('pins.weight desc, pins.created_at desc')
      .limit(6)
  end

  def important_pinboards
    Pinboard.where(is_important: true, access_rights: :public)
  end

  def important_companies
    Company.where(is_important: true, is_published: true)
  end

  def followed_activities
    Activity.followed_by_user(id)
  end

  def click_activities
    activities.where(action: :click)
  end

  def limbo_pins
    Pin.limbo
  end

  def owned_companies
    Company.joins(:roles).where(roles: { user_id: id, owner_type: 'Company' })
  end

  def published_companies
    Company.where(is_published: true).order('created_at DESC')
  end

  def followed_companies
    Company.joins(:followers).where(followers: { user_id: id, favoritable_type: 'Company' })
  end

  def company_invite_tokens
    Token.where(name: :invite, owner_type: 'Company').select_by_user(id, emails.pluck(:address))
  end

  (Cloudchart::ROLES + [:guest]).map(&:to_s).each do |role_name|
    define_method("#{role_name}?") do
      !!roles.find { |role| role.owner_id.nil? && role.value == role_name }
    end
  end

  def authorized?
    authorized_at.present?
  end

  def system_role_ids=(args)
    roles = args.select(&:present?)
    roles = roles.uniq.map { |value| Role.new(value: value) } if roles.any?
    self.system_roles = roles
  end

  def has_already_voted_for?(object)
    votes.map(&:destination_id).include?(object.id)
  end

  def full_name_or_email
    @full_name_or_email ||= full_name.blank? ? emails.first.address : full_name
  end

  def full_name_or_twitter
    full_name.present? ? full_name : "@#{twitter}"
  end

  def email
    emails.first.try(:address)
  end

  def unverified_email
    tokens.find_by(name: :email_verification).try(:data).try(:[], :address)
  end

  def email=(email)
    self.emails = [Email.new(address: email)] unless email.blank?
  end

  def invite=(invite)
    @invite = Token.where(name: :invite).find(invite) rescue Token.where(name: :invite).find(Cloudchart::RFC1751::decode(invite)) rescue nil
  end

  def invited_by_companies
    tokens = Token.includes(:owner)
      .where(name: 'invite', owner_type: 'Company')
      .select_by_user(id, emails.pluck(:address))

    companies = tokens.map(&:owner)
  end

  # def validate_email
  #   errors.add(:email, emails.first.errors[:address]) unless emails.first.valid?
  # end

  def should_generate_new_friendly_id?
    twitter_changed? && twitter.present?
  end

  def blank_company
    companies.select { |company| company.name.blank? && company.logotype.blank? }.first
  end

  # needed for rails_admin
  def should_create_tour_tokens=(value)
    should_create_tour_tokens! if value == '1'
  end

  def twitter_url
    "https://twitter.com/#{twitter}"
  end

private

  def mark_emails_for_destruction
    emails.each(&:mark_for_destruction)
  end

  def generate_password
    self.password = SecureRandom.uuid
  end

  def nillify_last_sign_in_at
    self.last_sign_in_at = nil
  end

  def nillify_slug
    self.slug = nil
  end

  def extract_twitter
    self.twitter = twitter.to_s.split('/').last.gsub(/@/, '')
  end

  def create_tour_tokens
    tokens << [Token.new(name: :welcome_tour), Token.new(name: :insight_tour)]
  end

  def create_unicorn_role
    roles.create(value: 'unicorn')
  end

  def validate_twitter_handle_for_invite
    if errors.added?(:twitter, :taken) && self.class.friendly.find(twitter).last_sign_in_at.present?
      errors.add(:base, I18n.t('errors.messages.twitter_handle_invited_and_logged_in'))
    elsif errors.added?(:twitter, :taken)
      errors.add(:base, I18n.t('errors.messages.twitter_handle_invited'))
    end
  end

  # def build_blank_emails
  #   emails.build
  # end

end
