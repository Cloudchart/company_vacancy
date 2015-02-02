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
data.each do |key,values|
  name = key.to_s.singularize
  json.set! key, values.flatten.compact.uniq do |value|
    json.partial! name, :"#{name}" => value
  end
end
