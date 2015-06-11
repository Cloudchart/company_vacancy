json.partial! 'user', user: viewer, siblings: siblings, edges: edges, cache: cache


# Edges
#


json_edge! json, :important_companies_ids, edges do
  viewer.important_companies.map(&:id)
end


#
# / Edges
