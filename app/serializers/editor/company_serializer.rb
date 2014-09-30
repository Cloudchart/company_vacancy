module Editor
  class CompanySerializer < ActiveModel::Serializer
    
    self.root = false
    
    attributes  :uuid, :name, :description, :is_published
    attributes  :slug, :site_url, :established_on, :tag_list
    attributes  :logotype, :logotype_url, :company_url

    # deprecated
    # has_one :logo, serializer: Editor::LogoSerializer
    
    def logotype
      {
        url:      object.logotype.url,
        width:    object.logotype.width,
        height:   object.logotype.height,
      } if object.logotype_uid
    end

    def logotype_url
      object.logotype.url if object.logotype_uid
    end


    def company_url
      company_path(object)
    end
    
  end
end
