class Friend < ActiveRecord::Base
  include Uuidable
  include Tire::Model::Search
  include Tire::Model::Callbacks  

  has_and_belongs_to_many :users
  has_one :social_network, class_name: CloudProfile::SocialNetwork, primary_key: :external_id, foreign_key: :provider_id

  scope :related_to_company, -> company_id { includes(users: { people: :company }).where(companies: { uuid: company_id }) }
  scope :working_in_company, -> company_id { includes(social_network: { user: { people: :company } }).where(companies: { uuid: company_id }) }

  settings ElasticSearchNGramSettings do
    mapping do
      indexes :full_name, analyzer: 'ngram_analyzer'
      indexes :company_ids, index: :not_analyzed
    end
  end

  def self.search(params)
    tire.search(load: true) do
      if params[:query].present?
        query { string Cloudchart::Utils.tokenized_query_string(params[:query], :full_name) }
      end

      filter :term, company_ids: params[:company_id]
    end
  end

  def to_indexed_json
    to_json( methods: [:company_ids])
  end

  def company_ids
    users.joins(people: :company).select('companies.uuid').map(&:id)
  end

end
