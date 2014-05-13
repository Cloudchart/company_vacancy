class Friend < ActiveRecord::Base
  include Uuidable
  include Tire::Model::Search
  include Tire::Model::Callbacks  

  has_and_belongs_to_many :users

  scope :by_company, -> company_id { includes(users: { people: :company }).where(companies: { uuid: company_id }) }

  settings ElasticSearchNGramSettings do
    mapping do
      indexes :full_name, analyzer: 'ngram_analyzer'
    end
  end

  def self.search(params)
    tire.search(load: true) do
      query { string "full_name:#{params[:query]}" } if params[:query].present?
    end
  end

end
