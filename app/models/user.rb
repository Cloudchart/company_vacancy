class User < ActiveRecord::Base
  include Uuidable
  
  attr_accessor :current_password

  before_destroy :mark_emails_for_destruction

  has_secure_password

  #has_one   :avatar, as: :owner, dependent: :destroy
  #accepts_nested_attributes_for :avatar, allow_destroy: true
  dragonfly_accessor :avatar

  has_and_belongs_to_many :friends

  has_many  :emails, -> { order(:address) }, class_name: CloudProfile::Email, dependent: :destroy
  has_many  :social_networks, inverse_of: :user, class_name: CloudProfile::SocialNetwork, dependent: :destroy
  has_many  :tokens, as: :owner, dependent: :destroy
  has_many  :people, dependent: :destroy
  has_many  :companies, through: :people
  has_many  :charts, through: :companies
  has_many  :votes, as: :source
  has_many  :activities, dependent: :destroy
  has_many  :subscriptions, dependent: :destroy
  has_many  :vacancies, foreign_key: :author_id
  has_many  :vacancy_responses
  has_many  :favorites, dependent: :destroy
  
  validates :first_name, :last_name, presence: true, if: :should_validate_name?

  rails_admin do

    list do
      exclude_fields :password_digest
    end

    edit do
      include_fields :is_admin
    end

  end
  
  def should_validate_name?
    @should_validate_name
  end
  
  def should_validate_name!
    @should_validate_name = true
  end

  def has_already_voted_for?(object)
    votes.map(&:destination_id).include?(object.id)
  end

  def full_name
    @full_name ||= [first_name, last_name].compact.join(' ')
  end

  def full_name=(full_name)
    parts             = full_name.split(/\s+/).select { |part| part.present? }
    self.first_name   = parts.first
    self.last_name    = parts.drop(1).join(' ')
  end

  def full_name_or_email
    @full_name_or_email ||= full_name.blank? ? emails.first.address : full_name
  end
  
  def has_proper_name?
    first_name.present? && last_name.present?
  end
  
  def email
    emails.first.address
  end

private

  def mark_emails_for_destruction
    emails.each(&:mark_for_destruction)
  end

end
