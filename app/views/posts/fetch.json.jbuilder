relations   = parse_relations_query(params[:relations])

data        = {}


# Fetch
#
data[:posts] = Post.includes(build_relations_includes(relations)).find(params[:ids])


# Traverse
#
data[:posts].each do |post|
  traverse_relations(post, relations, data)
end


# Render
#
render_jbuilder_objects(json, data)
