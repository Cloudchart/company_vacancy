relations   = parse_relations_query(params[:relations])
data        = {}


# Fetch
#
data[:pinboards] = current_user.pinboards.includes(build_relations_includes(relations))
data[:pinboards].concat(Pinboard.includes(build_relations_includes(relations)).where(user_id: nil))


# Traverse
#
data[:pinboards].each do |pinboard|
  traverse_relations(pinboard, relations, data)
end


# Render
#
data.each do |key,values|
  name = key.to_s.singularize
  json.set! key, values.flatten.compact.uniq do |value|
    json.partial! name, :"#{name}" => value
  end
end
