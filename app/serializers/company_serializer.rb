class CompanySerializer < ActiveModel::Serializer

  attributes  :uuid, :name, :description
  attributes  :meta, :flags
  
  alias_method :current_user, :scope
  alias_method :company, :object

  def meta
    {
      people_size: company.people.size,
      vacancies_size: company.vacancies.size,
      tags: company.tags.pluck(:name),
      company_url: company_path(company),
      logotype_url: company.logotype.try(:url)
    }
  end

  def flags
    {
      is_read_only: Ability.new(current_user).cannot?(:manage, company),
      is_trusted: Ability.new(current_user).can?(:fully_read, company),
      can_follow: Ability.new(current_user).can?(:follow, company),
      is_followed: (current_user.favorites.pluck(:favoritable_id).include?(company.id) if current_user)
    }
  end

end
