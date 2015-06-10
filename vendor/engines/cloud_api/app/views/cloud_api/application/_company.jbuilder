# Helpers
#

def insights(company, siblings, cache)
  Company.preload_insights(siblings, cache)
  company.insights
end

def posts(company, siblings, cache)
  preload_associations(siblings, cache, :posts)
  company.posts
end

#
# / Helpers


# Attributes
#

json.(company, :uuid, :name, :description)
json.(company, :established_on)
json.(company, :is_name_in_logo, :is_published, :is_important, :site_url, :slug)

json.logotype_url company.logotype.url if company.logotype_stored?

json.company_url  main_app.company_path(company)

#
# / Attributes


# Edges
#

json_edge! json, :insights_count, edges do
  insights(company, siblings, cache).size
end

json_edge! json, :posts_count, edges do
  posts(company, siblings, cache).size
end

json_edge! json, :is_followed, edges do
  preload_associations(siblings, cache, :followers)
  !!company.followers.find { |f| f.user_id == current_user.id }
end

json_edge! json, :is_invited, edges do
  preload_associations(siblings, cache, :roles)
  !!company.roles.find { |r| r.user_id == current_user.id && r.pending_value.present? }
end

#
# / Edges
