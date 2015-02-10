data  = {}
query = parse_relations_query(params[:relations])


@source = User

def gather_includes(source, query)
  return {} unless query.present? && source.respond_to?(:reflect_on_association)

  includes = {}

  query.each do |key, value|
    if association = source.reflect_on_association(key)
      includes[key.to_sym] = gather_includes(association.klass, value)
    end
  end

  includes

end


# def prefetch(source, query, includes = {})
#
#   result    = {
#     source:     source,
#     includes:   [],
#     children:   [],
#     methods:    []
#   }
#
#   query.each do |key, value|
#
#     result[:includes] << gather_includes(source, query)
#
#     if source.respond_to?(key)
#       result[:children] << prefetch(source.public_send(key).klass, value)
#     else
#       result[:methods] << key
#     end
#   end unless query.nil?
#
#   unless result[:includes].empty?
#     result[:source] = result[:source].includes(result[:includes])
#   end
#
#   result
#
# end
#
#
#
# loaders = prefetch(@source, query)

json.includes gather_includes(@source, query)

unless gather_includes(@source, query).empty?
  @source = @source.includes(gather_includes(@source, query))
end


#json.loaders loaders


json.query do
 populate_data_for_jbuilder(json, data, @source, query)
end

#
# data.each do |key, values|
#   name = key.to_s.singularize
#   json.set! key, values.flatten.compact.uniq do |value|
#     json.partial! name, :"#{name}" => value
#   end
# end
