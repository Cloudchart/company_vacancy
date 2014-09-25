# TODO: don not load data without cancan ability
class CompanyEditorSerializer < ActiveModel::Serializer
  attributes :id, :uuid, :name, :country, :description, :is_listed, :logotype, :slug, :site_url
  attributes :sections, :available_sections, :available_block_types
  attributes :blocks_url, :people_url, :vacancies_url, :logotype_url, :company_url
  attributes :verify_site_url, :download_verification_file_url, :default_host
  attributes :industry_ids, :is_site_url_verified
  attributes :charts_for_select, :established_on, :tag_list, :all_tags
  attributes :is_editor, :is_public_reader, :is_trusted_reader

  has_many :charts, serializer: BurnRateChartSerializer
  has_many :blocks, serializer: BlockEditorSerializer

  # deprecated
  # has_one :logo, serializer: Editor::LogoSerializer

  alias_method :current_user, :scope
  alias_method :company, :object
  
  def is_editor
    Ability.new(current_user).can?(:manage, company)
  end

  def is_public_reader
    Ability.new(current_user).can?(:partly_read, company)
  end

  def is_trusted_reader
    Ability.new(current_user).can?(:fully_read, company)
  end

  def is_site_url_verified
    object.site_url.present? && object.tokens.find_by(name: :site_url_verification).blank?
  end

  def id
    object.to_param
  end

  def sections
    object.sections.marshal_dump
  end

  def industry_ids
    object.industries.ids
  end

  def all_tags
    Tag.where(is_acceptable: true).map { |tag| { id: tag.id, name: tag.name } }
  end
  
  def charts_for_select
    object.charts.joins(nodes: :people).select(:uuid, :title).uniq
  end

  def available_sections
    object.class::Sections.map do |section|
      {
        key:    section.downcase,
        title:  section
      }
    end
  end
  
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

  def available_block_types
    object.class::BlockTypes.map do |type|
      {
        type:   type,
        icon:   I18n.t("block.icons.#{type}"),
        title:  I18n.t("block.titles.#{type}")
      }
    end
  end
  
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

  def verify_site_url
    verify_site_url_company_path(object.id)
  end

  def download_verification_file_url
    download_verification_file_company_path(object.id)
  end

  def default_host
    ENV['ACTION_MAILER_DEFAULT_HOST']
  end

end
