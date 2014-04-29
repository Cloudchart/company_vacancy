module CloudBlueprint
  class Chart < ActiveRecord::Base
    include Uuidable
    
    
    belongs_to :company, class_name: Company.name
    
    validates_presence_of :title
    validates_presence_of :company_id
    
  end
end
