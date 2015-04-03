class User < ActiveRecord::Base
  include Uuidable
  include Fullnameable
  include FriendlyId

  attr_accessor :current_password
  attr_reader :invite

  # before_validation :build_blank_emails, unless: -> { emails.any? }
  before_validation :generate_password, if: -> { password.blank? }
  before_destroy :mark_emails_for_destruction

  friendly_id :twitter, use: :slugged

  dragonfly_accessor :avatar

  has_secure_password

  has_and_belongs_to_many :friends

  has_many :emails, -> { order(:address) }, dependent: :destroy
  has_many :social_networks, inverse_of: :user, class_name: 'CloudProfile::SocialNetwork', dependent: :destroy
  has_many :oauth_providers, dependent: :destroy
  has_many :tokens, as: :owner, dependent: :destroy
  has_many :charts, through: :companies
  has_many :votes, as: :source
  has_many :activities, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :vacancies, foreign_key: :author_id
  has_many :vacancy_responses
  has_many :favorites, dependent: :destroy
  has_many :followers, as: :favoritable, dependent: :destroy, class_name: 'Favorite'
  has_many :roles, dependent: :destroy
  has_many :system_roles, -> { where(owner: nil) }, class_name: 'Role', dependent: :destroy
  has_many :people, dependent: :destroy
  has_many :pinboards, dependent: :destroy
  has_many :pins, dependent: :destroy
  has_many :companies, through: :roles, source: :owner, source_type: 'Company'

  # Roles on Pinboards
  #
  { readable: [:reader, :editor], writable: :editor, followable: :follower }.each do |scope, role|
    has_many :"#{scope}_pinboards_roles", -> { where(value: role) }, class_name: Role
    has_many :"#{scope}_pinboards", through: :"#{scope}_pinboards_roles", source: :owner, source_type: Pinboard
  end

  validates :full_name, presence: true, if: :should_validate_name?
  validates :invite, presence: true, if: :should_validate_invite?
  validates :twitter, uniqueness: true, allow_blank: true

  # validate :validate_email, on: :create

  scope :unicorns, -> { joins { :system_roles }.where(roles: { value: 'unicorn'}) }

  class << self
    def create_with_twitter_omniauth_hash(hash)
      avatar_url = hash.info.image.present? ? hash.info.image.sub('_normal', '') : nil

      create!(
        full_name:    hash.info.name,
        twitter:      hash.info.nickname,
        avatar_url:   avatar_url
      )
    end

    def find_by_email(email)
      Email.includes(:user).find_by(address: email).user rescue nil
    end
  end # of class methods

  def featured_insights
    Pin.featured
  end

  def followed_activities
    Activity.followed_by_user(id)
  end

  def published_companies
    Company.joins(:roles).where(is_published: true, roles: { user_id: id, owner_type: 'Company' })
  end

  def followed_companies
    Company.joins(:followers).where(followers: { user_id: id, favoritable_type: 'Company' })
  end

  def admin?
    !!roles.find { |role| role.owner_id == nil && role.value == 'admin' }
  end

  def editor?
    !!roles.find { |role| role.owner_id == nil && role.value == 'editor' }
  end

  def guest?
    !!roles.find { |role| role.owner_id == nil && role.value == 'guest' }
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

  def email
    emails.first.try(:address)
  end

  def email=(email)
    self.emails = [Email.new(address: email)]
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

  def should_validate_invite?
    @should_validate_invite
  end

  def should_validate_invite!
    @should_validate_invite = true
  end

  def should_validate_name?
    @should_validate_name
  end

  def should_validate_name!
    @should_validate_name = true
  end

  # def validate_email
  #   errors.add(:email, emails.first.errors[:address]) unless emails.first.valid?
  # end

  def blank_company
    companies.select { |company| company.name.blank? && company.logotype.blank? }.first
  end

private

  def mark_emails_for_destruction
    emails.each(&:mark_for_destruction)
  end

  def generate_password
    self.password = SecureRandom.uuid
  end

  # def build_blank_emails
  #   emails.build
  # end

end
