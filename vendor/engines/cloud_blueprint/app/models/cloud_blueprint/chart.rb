module CloudBlueprint
  class Chart < ActiveRecord::Base
    include Uuidable

    after_validation :generate_slug
    
    belongs_to :company, class_name: Company.name
    
    has_many :nodes, dependent: :destroy
    has_many :identities
    has_many :vacancies, through: :nodes
    has_many :people, through: :nodes
    
    validates :title, presence: true
    validate :title_uniqueness_inside_company, on: :update

  private
    
    def generate_slug
      new_slug = title.parameterize

      self.slug = if new_slug.present?
        available_slugs = company.charts.pluck(:slug)

        i = 1
        while available_slugs.include?(new_slug)
          new_slug += '-0' unless new_slug.match(/-\d$/)
          new_slug.gsub!(/-\d$/, "-#{i}")
          i += 1
        end

        new_slug
      else
        nil
      end
    end

    def title_uniqueness_inside_company
      if company.charts.map { |chart| chart.title.downcase.squish }.include?(title.downcase.squish)
        errors.add :title, I18n.t('errors.messages.title_is_not_unique')
      end
    end
    
  end
end
