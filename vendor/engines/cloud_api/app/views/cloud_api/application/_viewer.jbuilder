json.partial! 'user', user: viewer, siblings: siblings, edges: edges, cache: cache, scope: scope

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

json_edge! json, :feed_dates, edges do
  User.preload_feed_pinboards(siblings, cache)
  User.preload_feed_pins(siblings, cache)

  dates = []
  dates.concat viewer.feed_pinboards.map { |p| p.created_at.to_date }
  dates.concat viewer.feed_pins.map { |p| p.created_at.to_date }
  dates.concat viewer.feed_features.map { |f| f.effective_from.to_date }
  dates.uniq.sort
end
