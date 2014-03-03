class Friend < ActiveRecord::Base
  include Uuidable
  include Tire::Model::Search
  include Tire::Model::Callbacks  

  belongs_to :user

  scope :by_company, -> company_id { includes(user: { people: :company }).where('companies.uuid = ?', company_id).references(:companies) }

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
