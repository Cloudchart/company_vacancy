json.partial! 'user', user: viewer, siblings: siblings, edges: edges, cache: cache


# Edges
#


json_edge! json, :important_companies_ids, edges do
  viewer.important_companies.map(&:id)
end


json_edge! json, :published_companies, edges do
  viewer.published_companies.map do |c|
    {
      id:     c.id,
      name:   c.name
    }
  end
end


#
# / Edges
