json.(story, :uuid, :company_id)
json.(story, :name, :description)
json.(story, :created_at, :updated_at)

json.formatted_name story.name.gsub('_', ' ')

json.company_story_url company_story_path(company.to_param, story.name)
