company_ids = companies.map(&:id)

people   = companies.map(&:people).flatten
taggings = companies.map(&:taggings).flatten
tags     = companies.map(&:tags).flatten.uniq
posts    = Post.only_public.includes(:pins).where(owner_id: company_ids)
pins     = posts.map(&:pins).flatten

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

json.posts do
  json.partial! 'post', collection: posts, as: :post
end

json.pins do
  json.partial! 'pin', collection: pins, as: :pin
end