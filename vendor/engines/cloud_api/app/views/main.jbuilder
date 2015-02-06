data  = {}
query = parse_relations_query(params[:relations])

json.query do
  populate_data_for_jbuilder(json, data, @source, query)
end

data.each do |key, values|
  name = key.to_s.singularize
  json.set! key, values.flatten.compact.uniq do |value|
    json.partial! name, :"#{name}" => value
  end
end
