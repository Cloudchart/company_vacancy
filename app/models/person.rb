class Person < ActiveRecord::Base
  include Uuidable
  include Tire::Model::Search
  include Tire::Model::Callbacks

  belongs_to :user
  belongs_to :company

  has_one :block_identity, as: :identity, inverse_of: :identity, dependent: :destroy
  has_and_belongs_to_many :vacancy_reviews, class_name: 'Vacancy', join_table: 'vacancy_reviewers'
  # has_paper_trail
  
  has_many :node_identities, as: :identity, dependent: :destroy, class_name: CloudBlueprint::Identity

  # validates :first_name, :last_name, presence: true
  validates :full_name, presence: true

  scope :later_then, -> (date) { where arel_table[:updated_at].gteq(date) }

  rails_admin do
    object_label_method :full_name

    list do
      exclude_fields :uuid, :phone, :email

      field :user do
        pretty_value { bindings[:view].mail_to value.email, value.full_name if value }
      end

      field :company do
        pretty_value { bindings[:view].link_to(value.name, bindings[:view].main_app.company_path(value)) }
      end
    end

  end

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
  
  def full_name=(full_name)
    parts             = full_name.split(/\s+/).select { |part| part.present? }
    self.first_name   = parts.first
    self.last_name    = parts.drop(1).join(' ')
  end

  def as_json_for_chart
    as_json(only: [:uuid, :full_name, :first_name, :last_name, :email, :occupation, :salary])
  end

end
