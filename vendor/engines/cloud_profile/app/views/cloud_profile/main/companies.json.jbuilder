company_ids = @companies.map(&:id)

people   = @companies.map(&:people).flatten
taggings = @companies.map(&:taggings).flatten
tags     = @companies.map(&:tags).flatten.uniq

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

json.roles do
  json.partial! 'role', collection: @roles, as: :role
end

json.favorites do
  json.partial! 'favorite', collection: @favorites, as: :favorite
end

json.tokens do
  json.partial! 'token', collection: @tokens, as: :token
end