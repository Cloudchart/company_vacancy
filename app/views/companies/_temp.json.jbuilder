company_ids = companies.map(&:id)

companies = Company.includes(:people, :taggings, :tags, blocks: [:block_identities], posts: [:pins, :visibilities]).find(company_ids)

blocks   = companies.map(&:blocks).flatten
people   = companies.map(&:people).flatten
taggings = companies.map(&:taggings).flatten
tags     = companies.map(&:tags).flatten.uniq

json.companies do
  json.partial! 'company', collection: companies, as: :company, with_count: true, with_tags: true
end

json.blocks do
  json.partial! 'block', collection: blocks, as: :block
end

json.people do
  json.partial! 'person', collection: people, as: :person
end