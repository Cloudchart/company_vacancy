class CompanyEditorSerializer < ActiveModel::Serializer
  attributes :id, :uuid, :name, :description, :is_published, :logotype, :slug, :site_url
  # attributes :sections, :available_sections, :available_block_types
  attributes :blocks_url, :people_url, :vacancies_url, :logotype_url, :company_url
  attributes :default_host, :settings, :established_on, :tag_list
  attributes :is_editor, :is_trusted_reader, :is_chart_with_nodes_created
  attributes :meta, :flags

  has_many :charts
  # has_many :burn_rate_charts, serializer: BurnRateChartSerializer
  has_many :blocks, serializer: BlockEditorSerializer

  # deprecated
  # has_one :logo, serializer: Editor::LogoSerializer

  alias_method :current_user, :scope
  alias_method :company, :object
  

  def meta
    {
      logotype_url: company.logotype.try(:url),
      invitable_roles: Company::INVITABLE_ROLES
    }
  end

  def flags
    {
      is_read_only: Ability.new(current_user).cannot?(:update, company),
      can_follow: Ability.new(current_user).can?(:follow, company),
      is_followed: (current_user.favorites.pluck(:favoritable_id).include?(company.id) if current_user)
    }
  end


  def is_editor
    Ability.new(current_user).can?(:update, company)
  end

  def is_trusted_reader
    Ability.new(current_user).can?(:finance, company)
  end

  # def include_burn_rate_charts?
  #   is_editor || is_trusted_reader
  # end

  def is_chart_with_nodes_created
    company.charts.first.try(:nodes).try(:any?)
  end

  def attributes
    data = super

    data.delete(:settings) unless is_editor

    data
  end

  # def burn_rate_charts
  #   company.charts
  # end

  def settings
    {
      verify_site_url: verify_site_url_company_path(company.id),
      download_verification_file_url: download_verification_file_company_path(company.id),
      is_site_url_verified: company.site_url.present? && company.tokens.find_by(name: :site_url_verification).blank?
    }
  end

  def id
    object.to_param
  end

  # def sections
  #   object.sections.marshal_dump
  # end

  # def available_sections
  #   object.class::Sections.map do |section|
  #     {
  #       key:    section.downcase,
  #       title:  section
  #     }
  #   end
  # end
  
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

  # def available_block_types
  #   object.class::BlockTypes.map do |type|
  #     {
  #       type:   type,
  #       icon:   I18n.t("block.icons.#{type}"),
  #       title:  I18n.t("block.titles.#{type}")
  #     }
  #   end
  # end
  
  def company_url
    company_path(object.id)
  end

  def blocks_url
    company_blocks_path(object)
  end
  
  def people_url
    company_people_path(object)
  end

  def vacancies_url
    company_vacancies_path(object)
  end

  def default_host
    ENV['ACTION_MAILER_DEFAULT_HOST']
  end

end
