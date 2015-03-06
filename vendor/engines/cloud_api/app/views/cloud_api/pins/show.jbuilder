data  = {}
query = parse_relations_query(params[:relations])

populate_data_for_jbuilder(data, @pin, query)

data.each do |key, values|
  name = key.to_s.singularize
  json.set! key, values.flatten.compact.uniq do |value|
    json.partial! name, :"#{name}" => value
  end
end
