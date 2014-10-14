class CompanySerializer < ActiveModel::Serializer

  attributes  :uuid, :name, :description
  attributes  :is_trusted, :is_read_only, :can_follow, :is_followed
  attributes  :logotype_url
  attributes  :meta, :flags
  
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

  def is_followed
    current_user.favorites.pluck(:favoritable_id).include?(company.id)
  end
  
  def logotype_url
    company.logotype.url if company.logotype_stored?
  end

  def meta
    {
      people_count: company.people.count,
      tags: company.tags.pluck(:name),
      path: company_path(company)
    }
  end

  def flags
    {
      is_in_company: company.users.include?(current_user),
      is_invited: is_invited
    }
  end

private

  def is_invited
    Token.where(name: 'invite', owner_type: 'Company', owner_id: company.id)
      .select_by_user(current_user.uuid, current_user.emails.pluck(:address)).size > 0
  end
end
