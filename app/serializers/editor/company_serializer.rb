module Editor
  class CompanySerializer < ActiveModel::Serializer
    
    self.root = false
    
    attributes :uuid, :name, :description, :url
    
    def url
      company_path(object)
    end
    
  end
end
