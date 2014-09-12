module CloudBlueprint
  class Chart < ActiveRecord::Base
    include Uuidable

    after_validation :build_slug
    
    belongs_to :company, class_name: Company.name
    
    has_many :nodes, dependent: :destroy
    has_many :identities
    has_many :vacancies, through: :nodes
    has_many :people, through: :nodes
    
    validates :title, presence: true
    validate :title_uniqueness_inside_company

  private
    
    def build_slug
      self.slug = title.parameterize
    end

    def title_uniqueness_inside_company
      if company.charts.map { |chart| chart.title.downcase.squish }.include?(title.downcase.squish)
        errors.add :title, I18n.t('errors.messages.title_is_not_unique')
      end
    end
    
  end
end
