class CompanyEditorSerializer < ActiveModel::Serializer

  attributes :id, :uuid, :name, :country, :description, :is_listed, :logotype
  attributes :sections, :available_sections, :available_block_types
  attributes :blocks_url, :people_url, :vacancies_url, :logotype_url, :company_url
  attributes :verify_url, :download_verification_file_url
  attributes :industry_ids, :chart_ids, :short_name, :url, :is_url_verified, :chart_permalinks

  has_many :blocks, serializer: BlockEditorSerializer
  has_one :logo, serializer: Editor::LogoSerializer
  
  def id
    object.to_param
  end

  def sections
    object.sections.marshal_dump
  end
  
  
  def industry_ids
    object.industries.map(&:id)
  end
  

  def chart_ids
    object.charts.map(&:id)
  end

  def chart_permalinks
    object.charts.map(&:permalink)
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
    company_path(object)
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

  def verify_url
    verify_url_company_path(object.id)
  end

  def download_verification_file_url
    download_verification_file_company_path(object.id)
  end

  # def formatted
    
  # end

  def is_url_verified
    object.url.present? && object.tokens.find_by(name: :url_verification).blank?
  end

end
