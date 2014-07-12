module Editor
  class CompanySerializer < ActiveModel::Serializer
    
    self.root = false
    
    attributes :uuid, :name, :description, :url
    

    has_one :logo, serializer: Editor::LogoSerializer


    def url
      company_path(object)
    end
    
  end
end
