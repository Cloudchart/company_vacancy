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

json_edge! json, :is_authenticated, edges do
  user_authenticated?
end

json_edge! json, :has_email, edges do
  viewer.emails.size > 0
end

json_edge! json, :has_email_token, edges do
  !!viewer.tokens.find { |t| t.name == 'email_verification' }
end
