json.(company, :uuid, :name, :description)
json.(company, :established_on)
json.(company, :created_at)
json.(company, :is_name_in_logo, :is_published, :is_important, :site_url, :slug)

json.logotype_url company.logotype.url if company.logotype_stored?

json.company_url  main_app.company_path(company)

if with_count
  public_posts = company.posts.select { |post| post.visibility.try(:value) == 'public' }
  insights = public_posts.map(&:pins).flatten.select { |pin| pin.content.present? && pin.parent_id.blank? }

  json.posts_count public_posts.size
  json.insights_count insights.size
end

if with_tags
  json.tag_names company.tags.map(&:name)
end