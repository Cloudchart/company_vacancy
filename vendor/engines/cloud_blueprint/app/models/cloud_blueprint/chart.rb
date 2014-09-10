module CloudBlueprint
  class Chart < ActiveRecord::Base
    include Uuidable

    before_validation :assign_permalink
    
    belongs_to :company, class_name: Company.name
    
    has_many :nodes, dependent: :destroy
    has_many :identities
    has_many :vacancies, through: :company
    has_many :people, through: :company
    
    validates :title, presence: true

  private
    
    def assign_permalink
      self.permalink = title.downcase.squish.gsub(/\s/, '-')
    end
    
  end
end
