module CloudBlueprint
  class Chart < ActiveRecord::Base
    include Uuidable

    before_validation :build_slug
    
    belongs_to :company, class_name: Company.name
    
    has_many :nodes, dependent: :destroy
    has_many :identities
    has_many :vacancies, through: :nodes
    has_many :people, through: :nodes
    
    # TODO: validate uniqueness inside company
    validates :title, presence: true

  private
    
    # TODO: escape unwelcome chars like '?'
    def build_slug
      self.slug = title.downcase.squish.gsub(/\s/, '-')
    end
    
  end
end
