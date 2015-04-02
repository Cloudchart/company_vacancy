class StorySerializer < ActiveModel::Serializer

  attributes :uuid, :name, :description, :company_id, :created_at, :updated_at
  attributes :formatted_name, :company_story_url

  alias_method :company, :scope
  alias_method :story, :object

  def company_story_url
    company_story_path(company.to_param, story.name)
  end

  def formatted_name
    story.name.gsub(/_/, ' ').mb_chars.downcase
  end

end
