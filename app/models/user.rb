class User < ActiveRecord::Base
  include Uuidable
  include Fullnameable
  
  attr_accessor :current_password
  attr_reader :invite

  before_destroy :mark_emails_for_destruction

  dragonfly_accessor :avatar

  has_secure_password

  has_and_belongs_to_many :friends
  
  default_scope -> { includes(:emails) }

  has_many :emails, -> { order(:address) }, class_name: 'CloudProfile::Email', dependent: :destroy
  has_many :social_networks, inverse_of: :user, class_name: 'CloudProfile::SocialNetwork', dependent: :destroy
  has_many :tokens, as: :owner, dependent: :destroy
  has_many :charts, through: :companies
  has_many :votes, as: :source
  has_many :activities, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :vacancies, foreign_key: :author_id
  has_many :vacancy_responses
  has_many :favorites, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :companies, through: :roles, source: :owner, source_type: 'Company'
  has_many :followed_companies, through: :favorites, source: :favoritable, source_type: 'Company'
  has_many :people, dependent: :destroy

  has_many :pinboards, dependent: :destroy
  has_many :pins, dependent: :destroy
  
  validates :first_name, :last_name, presence: true, if: :should_validate_name?
  validates :invite, presence: true, if: :should_validate_invite?
  validate :validate_email, on: :create

  rails_admin do

    list do
      include_fields :first_name, :is_admin, :companies, :created_at
      sort_by :created_at

      field :first_name do
        label 'Full name'
        formatted_value { bindings[:view].mail_to bindings[:object].email, bindings[:object].full_name }
      end

      field :companies do
        pretty_value { value.map { |company| bindings[:view].link_to(company.name, bindings[:view].main_app.company_path(company)) }.join(', ').html_safe }
      end

    end

  end

  def has_already_voted_for?(object)
    votes.map(&:destination_id).include?(object.id)
  end

  def full_name_or_email
    @full_name_or_email ||= full_name.blank? ? emails.first.address : full_name
  end
  
  def email
    emails.first.address
  end
  
  def email=(email)
    self.emails = [CloudProfile::Email.new(address: email)]
  end
  
  def self.find_by_email(email)
    CloudProfile::Email.includes(:user).find_by(address: email).user rescue nil
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

  def validate_email
    errors[:email] = emails.first.errors[:address] unless emails.first.valid?
  end

private

  def mark_emails_for_destruction
    emails.each(&:mark_for_destruction)
  end

end
