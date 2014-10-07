class CompanySerializer < ActiveModel::Serializer

  attributes  :uuid, :name, :description
  attributes  :is_trusted, :is_read_only
  attributes  :logotype_url
  
  
  def is_read_only
    !Ability.new(scope).can?(:manage, object)
  end
  
  
  def is_trusted
    Ability.new(scope).can?(:fully_read, object)
  end
  
  
  def logotype_url
    object.logotype.url if object.logotype_stored?
  end
  
  
end
