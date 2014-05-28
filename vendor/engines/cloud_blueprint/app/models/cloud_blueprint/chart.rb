module CloudBlueprint
  class Chart < ActiveRecord::Base
    include Uuidable
    
    
    belongs_to :company, class_name: Company.name
    
    has_many :nodes, dependent: :destroy
    
    has_many :identities
    
    has_many :people, through: :company
    
    validates_presence_of :title
    validates_presence_of :company_id
    
  end
end
