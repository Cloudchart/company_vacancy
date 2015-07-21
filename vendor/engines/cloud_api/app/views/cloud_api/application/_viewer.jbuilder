json.partial! 'user', user: viewer, siblings: siblings, edges: edges, cache: cache

# Edges
#
json_edge! json, :featured_companies, edges do
  preload_associations(viewer.featured_pinboards, [], :feature)

  viewer.featured_companies.map do |company|
    {
      id: company.id,
      name: company.name,
      featured_position: company.feature.position
    }
  end
end

json_edge! json, :published_companies, edges do
  viewer.published_companies.map do |c|
    {
      id:     c.id,
      name:   c.name
    }
  end
end

json_edge! json, :featured_pinboards, edges do
  preload_associations(viewer.featured_pinboards, [], :feature)

  viewer.featured_pinboards.map do |pinboard|
    {
      id: pinboard.id,
      title: pinboard.title,
      featured_position: pinboard.feature.position
    }
  end
end

json_edge! json, :is_authenticated, edges do
  user_authenticated?
end

json_edge! json, :has_email, edges do
  viewer.emails.size > 0
end

json_edge! json, :has_email_token, edges do
  !!viewer.tokens.find { |t| t.name == 'email_verification' }
end
