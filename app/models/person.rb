class Person < ActiveRecord::Base
  include Uuidable
  include Fullnameable
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include Admin::Person

  before_save :reset_verification, if: :twitter_changed?
  before_save :verify, if: :should_be_verified?

  dragonfly_accessor :avatar

  belongs_to :user
  belongs_to :company

  has_and_belongs_to_many :vacancy_reviews, class_name: 'Vacancy', join_table: 'vacancy_reviewers'
  has_many :block_identities, as: :identity, inverse_of: :identity, dependent: :restrict_with_error
  has_many :quotes, dependent: :restrict_with_error

  validates :full_name, presence: true

  scope :later_then, -> (date) { where arel_table[:updated_at].gteq(date) }

  settings ElasticSearchNGramSettings do
    mapping do
      indexes :first_name, type: 'string', analyzer: 'ngram_analyzer'
      indexes :last_name, type: 'string', analyzer: 'ngram_analyzer'
      indexes :company_id, index: :not_analyzed
    end
  end

  def self.search(params)
    tire.search(load: true) do
      if params[:query].present?
        query { string Cloudchart::Utils.tokenized_query_string(params[:query], [:first_name, :last_name]) }
      end

      filter :term, company_id: params[:company_id] if params[:company_id].present?
    end
  end

  def as_json_for_chart
    as_json(only: [:uuid, :full_name, :first_name, :last_name, :email, :occupation, :salary])
  end

  def should_be_verified!
    @should_be_verified = true
  end

  def should_be_verified?
    !!@should_be_verified
  end

private

  def reset_verification
    self.is_verified = false
    true
  end

  def verify
    if twitter_changed? && twitter.present?
      self.transaction do
        
        if user_found_by_twitter = User.find_by(twitter: twitter)
          self.user = user_found_by_twitter
          self.is_verified = true

          unless user_found_by_twitter.companies.include?(company)
            if invite = user_found_by_twitter.company_invite_tokens.select { |token| token.owner_id == company_id }.first
              value = invite.data[:role]
            else
              value = 'public_reader'
            end
            user_found_by_twitter.roles.create!(value: value, owner: company)
          end
        else
          self.user = nil
          # TODO: think about what to with a role here
        end

      end
    end
  end

end
