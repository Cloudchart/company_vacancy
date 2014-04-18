class Person < ActiveRecord::Base
  include Uuidable
  include Tire::Model::Search
  include Tire::Model::Callbacks

  belongs_to :user
  belongs_to :company
  # has_paper_trail

  validates :name, presence: true

  settings ElasticSearchNGramSettings do
    mapping do
      indexes :name, analyzer: 'ngram_analyzer'
    end
  end

  def self.search(params)
    tire.search(load: true) do
      query { string "name:#{params[:query]}" } if params[:query].present?
    end
  end

end
