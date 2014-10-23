class CompanySerializer < ActiveModel::Serializer

  attributes  :uuid, :name, :established_on, :description, :is_published, :site_url, :slug
  attributes  :meta, :flags
  
  alias_method :current_user, :scope
  alias_method :company, :object

  def meta
    {
      people_size: company.people.size,
      vacancies_size: company.vacancies.size,
      tags: company.tags.pluck(:name),
      company_url: company_url(company, host: ENV['ACTION_MAILER_DEFAULT_HOST']),
      logotype_url: company.logotype.try(:url),
      invitable_roles: Company::INVITABLE_ROLES,
      verify_site_url: verify_site_url_company_path(company),
      download_verification_file_url: download_verification_file_company_path(company)
    }
  end

  def flags
    {
      is_read_only: Ability.new(current_user).cannot?(:update, company),
      is_owner: Ability.new(current_user).can?(:manage, company),
      can_follow: Ability.new(current_user).can?(:follow, company),
      is_followed: (current_user.favorites.pluck(:favoritable_id).include?(company.id) if current_user),
      has_charts: company.charts.first.try(:nodes).try(:any?),
      is_site_url_verified: company.site_url.present? && company.tokens.find_by(name: :site_url_verification).blank?
    }
  end

end
