class Person < ActiveRecord::Base
  include Uuidable
  include Tire::Model::Search
  include Tire::Model::Callbacks

  belongs_to :user
  belongs_to :company
  has_and_belongs_to_many :vacancy_reviews, class_name: 'Vacancy', join_table: 'vacancy_reviewers'
  # has_paper_trail

  validates :first_name, :last_name, presence: true

  scope :later_then, -> (date) { where arel_table[:updated_at].gteq(date) }

  settings ElasticSearchNGramSettings do
    mapping do
      indexes :first_name, analyzer: 'ngram_analyzer'
      indexes :last_name, analyzer: 'ngram_analyzer'
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

  def full_name
    @full_name ||= [first_name, last_name].compact.join(' ')
  end

  def as_json_for_chart
    as_json(only: [:uuid, :first_name, :last_name, :email, :occupation])
  end

end
