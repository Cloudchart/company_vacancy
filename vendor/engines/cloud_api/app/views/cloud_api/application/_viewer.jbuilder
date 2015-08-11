json.partial! 'user', user: viewer, siblings: siblings, edges: edges, cache: cache

# Edges
#
json_edge! json, :published_companies, edges do
  viewer.published_companies.map do |c|
    {
      id:     c.id,
      name:   c.name
    }
  end
end

json_edge! json, :popular_pinboards_ids, edges do
  viewer.popular_pinboards.map(&:id)
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

json_edge! json, :favorite_insights_count, edges do
  viewer.favorite_insights.count
end
