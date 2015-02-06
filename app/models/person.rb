class Person < ActiveRecord::Base
  include Uuidable
  include Fullnameable
  include Tire::Model::Search
  include Tire::Model::Callbacks

  dragonfly_accessor :avatar

  belongs_to :user
  belongs_to :company

  has_one :block_identity, as: :identity, inverse_of: :identity, dependent: :destroy
  has_and_belongs_to_many :vacancy_reviews, class_name: 'Vacancy', join_table: 'vacancy_reviewers'
  has_many :quotes

  has_many :node_identities, as: :identity, dependent: :destroy, class_name: CloudBlueprint::Identity

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

end
