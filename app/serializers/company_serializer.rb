class CompanySerializer < ActiveModel::Serializer

  attributes :uuid, :name, :established_on, :description
  attributes :is_published, :slug, :tag_names, :is_name_in_logo
  attributes :site_url, :logotype_url, :company_url
  attributes :url, :facebook_share_url, :twitter_share_url
  attributes :meta, :flags, :post_ids
  
  alias_method :current_user, :scope
  alias_method :company, :object

  def logotype_url
    company.logotype.try(:url)
  end

  def company_url
    company_path(company)
  end

  def url
    main_app.company_url(company)
  end

  def facebook_share_url
    CloudApi::ApplicationController.helpers.facebook_share_url(url)
  end

  def twitter_share_url
    CloudApi::ApplicationController.helpers.twitter_share_url(url)
  end

  def meta
    {
      people_size: company.people.size,
      vacancies_size: company.vacancies.size,
      invitable_roles: Cloudchart::COMPANY_INVITABLE_ROLES,
      company_url: company_path(company),
      settings_url: company_path(company),
      verify_site_url: verify_site_url_company_path(company),
      download_verification_file_url: download_verification_file_company_path(company)
    }
  end

  def flags
    {
      is_read_only: Ability.new(current_user).cannot?(:update, company),
      can_follow: Ability.new(current_user).can?(:follow, company),
      is_followed: (current_user.favorites.pluck(:favoritable_id).include?(company.id) if current_user),
      is_site_url_verified: company.site_url.present? && company.tokens.find_by(name: :site_url_verification).blank?
    }
  end

end
