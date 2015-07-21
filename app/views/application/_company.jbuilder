json.(company, :uuid, :name, :description)
json.(company, :established_on, :site_url, :slug, :created_at, :user_id)
json.(company, :is_name_in_logo, :is_published)

json.logotype_url company.logotype.url if company.logotype_stored?

json.company_url main_app.company_path(company)

if with_count
  public_posts = company.posts.select { |post| post.visibility.try(:value) == 'public' }
  insights = public_posts.map(&:pins).flatten.select { |pin| pin.content.present? && pin.parent_id.blank? }

  json.posts_count public_posts.size
  json.insights_count insights.size
end

if with_tags
  json.tag_names company.tags.map(&:name)
end
