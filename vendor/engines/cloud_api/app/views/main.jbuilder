data  = {}
query = parse_relations_query(params[:relations])


def gather_includes(source, query)
  result = {}

  if query.present? && !query.empty? && source.respond_to?(:reflect_on_association)

    query.each do |key, value|
      if association = source.reflect_on_association(key)
        result[key.to_sym] = gather_includes(association.klass, value) if association.constructable?
      end
    end

  end

  result
end


includes = gather_includes(@source, query)

@source = @source.includes(includes) unless includes.empty?

@source = @source.public_send(*@starter)


json.query do
 populate_data_for_jbuilder(json, data, @source, query)
end


data.each do |key, values|
  name = key.to_s.singularize
  json.set! key, values.flatten.compact.uniq do |value|
    json.partial! name, :"#{name}" => value
  end
end
