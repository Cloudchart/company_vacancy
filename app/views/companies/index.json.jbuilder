company_ids = @companies.map(&:id)

people   = Person.where(company_id: company_ids)
taggings = Tagging.where(taggable_id: company_ids)
tags     = Tag.find(taggings.map(&:tag_id).uniq)

json.companies do
  json.partial! 'company', collection: @companies, as: :company
end

json.people do
  json.partial! 'person', collection: people, as: :person
end

json.taggings do
  json.partial! 'tagging', collection: taggings, as: :tagging
end

json.tags do
  json.partial! 'tag', collection: tags, as: :tag
end
