class StorySerializer < ActiveModel::Serializer

  attributes :uuid, :name, :description, :company_id, :created_at, :updated_at
  attributes :formatted_name

  alias_method :company, :scope
  alias_method :story, :object

  def formatted_name
    story.name.gsub(/_/, ' ').mb_chars.downcase
  end

end
