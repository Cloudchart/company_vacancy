data  = {}
query = parse_relations_query(params[:relations])


def __prepare(sources, query, data, json)
  grouped_sources = {}

  cache   = []
  edges   = (query || {}).delete('edges') { [] }.flatten.compact.uniq.map(&:to_sym)

  sources.each do |source|
    (grouped_sources[source.class] ||= []) << source
    (data[source.class.name.underscore.pluralize] ||= []) << { model: source, siblings: sources, cache: cache, edges: edges }
  end

  json.ids sources.map(&:id) unless sources.empty?

  query.each do |key, value|

    grouped_sources.each do |klass, instances|

      if klass.present? && klass.reflect_on_association(key)
        Preloadable::preload(instances, cache, key)
      end

    end

    children = sources.map { |source| source.try(key) }.flatten.compact.uniq

    json.set! key do
      __prepare(children, value, data, json)
    end

  end if query.present?

end


@source = @source.public_send(*@starter)

json.query do
  __prepare([@source].flatten, query, data, json)
end


data.each do |key, values|
  name = key.to_s.singularize
  json.set! key, values.flatten.compact.uniq do |value|
    json.partial! name, :"#{name}" => value[:model], :siblings => value[:siblings], cache: value[:cache], edges: value[:edges]
  end
end
