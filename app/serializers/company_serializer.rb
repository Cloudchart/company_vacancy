class CompanySerializer < ActiveModel::Serializer

  attributes  :uuid, :name, :description
  attributes  :is_trusted, :is_read_only, :can_follow, :is_followed
  attributes  :logotype_url
  attributes  :meta
  
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

  # TODO: remove, use favorite store instead
  def is_followed
    current_user.favorites.pluck(:favoritable_id).include?(company.id)
  end
  
  def logotype_url
    company.logotype.url if company.logotype_stored?
  end

  def meta
    {
      people_size: company.people.size,
      tags: company.tags.pluck(:name),
      company_url: company_path(company)
    }
  end

  # TODO: move all flags here
  def flags
    {}
  end

end
