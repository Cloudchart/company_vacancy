module Editor
  class CompanySerializer < ActiveModel::Serializer
    
    self.root = false
    
    attributes :uuid, :name, :description, :logotype_url, :url
    

    has_one :logo, serializer: Editor::LogoSerializer
    
    
    def logotype_url
      object.logotype.url if object.logotype_uid
    end


    def url
      company_path(object)
    end
    
  end
end
