json.(company, :uuid, :name, :description)
json.(company, :established_on)
json.(company, :is_name_in_logo, :is_published, :site_url, :slug)

json.logotype_url company.logotype.url if company.logotype_stored?

json.company_url  main_app.company_path(company)

if with_count
  posts = company.posts.includes(:pins)

  json.posts_count posts.size
  json.pins_count  posts.map(&:pins).flatten.size
end