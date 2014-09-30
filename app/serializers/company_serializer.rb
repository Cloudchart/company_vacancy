class CompanySerializer < ActiveModel::Serializer

  attributes :uuid, :name, :description
  
  attributes :logotype_url
  
  
  def logotype_url
    object.logotype.url if object.logotype_stored?
  end
  
  
end
