class CompanySerializer < ActiveModel::Serializer

  attributes  :uuid, :name, :description
  attributes  :is_trusted, :is_read_only, :can_follow
  attributes  :logotype_url
  
  alias_method :current_user, :scope
  alias_method :company, :object
  
  def is_read_only
    Ability.new(current_user).cannot?(:manage, company)
  end
  
  
  def is_trusted
    Ability.new(current_user).can?(:fully_read, company)
  end


  def can_follow
    Ability.new(current_user).can?(:follow, company)
  end
  
  
  def logotype_url
    company.logotype.url if company.logotype_stored?
  end
    
end
