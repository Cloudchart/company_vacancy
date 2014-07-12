class CompanyEditorSerializer < ActiveModel::Serializer
  

  attributes :uuid, :name, :country, :description, :url, :sections, :available_sections, :available_block_types
  attributes :blocks_url, :people_url, :vacancies_url
  

  has_many :blocks, serializer: BlockEditorSerializer
  
  has_one :logo, serializer: Editor::LogoSerializer
  
  def sections
    object.sections.marshal_dump
  end
  

  def available_sections
    object.class::Sections.map do |section|
      {
        key:    section.downcase,
        title:  section
      }
    end
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
  
  
  def url
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

end
