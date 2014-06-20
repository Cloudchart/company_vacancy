class Person < ActiveRecord::Base
  include Uuidable
  include Tire::Model::Search
  include Tire::Model::Callbacks


  scope :later_then, -> (date) { where arel_table[:updated_at].gteq(date) }


  belongs_to :user
  belongs_to :company
  has_and_belongs_to_many :vacancy_reviews, class_name: 'Vacancy', join_table: 'vacancy_reviewers'
  # has_paper_trail

  validates :first_name, :last_name, presence: true

  settings ElasticSearchNGramSettings do
    mapping do
      indexes :first_name, analyzer: 'ngram_analyzer'
      indexes :last_name, analyzer: 'ngram_analyzer'
    end
  end

  def self.search(params)
    tire.search(load: true) do
      if params[:query].present?
        query { string Tokenizable.tire_person_query_string(params[:query], [:first_name, :last_name]) }
      end
    end
  end

  def full_name
    @full_name ||= [first_name, last_name].compact.join(' ')
  end

  def as_json_for_chart
    as_json(only: [:uuid, :first_name, :last_name, :email, :occupation])
  end

end
