module Editor
  class CompanySerializer < ActiveModel::Serializer
    
    self.root = false
    
    attributes  :uuid, :name, :country, :description, :is_listed, :url, :short_name
    attributes  :logotype, :logotype_url
    attributes  :industry_ids
    

    has_one :logo, serializer: Editor::LogoSerializer
    
    
    def logotype
      {
        url:      object.logotype.url,
        width:    object.logotype.width,
        height:   object.logotype.height,
      } if object.logotype_uid
    end


    def industry_ids
      object.industries.map(&:to_param)
    end


    def logotype_url
      object.logotype.url if object.logotype_uid
    end


    def url
      company_path(object)
    end
    
  end
end
