data  = {}
query = parse_relations_query(params[:relations])


def __prepare(sources, query, data)
  grouped_sources = {}

  # sources.compact!
  # sources.uniq!

  cache   = []
  edges   = (query || {}).delete('edges') { [] }.flatten.compact.uniq.map(&:to_sym)
  puts query.inspect

  sources.each do |source|
    (grouped_sources[source.class] ||= []) << source
    (data[source.class.name.underscore.pluralize] ||= []) << { model: source, siblings: sources, cache: cache, edges: edges }
  end

  query.each do |key, value|

    grouped_sources.each do |klass, instances|

      if klass.present? && klass.reflect_on_association(key)
        ActiveRecord::Associations::Preloader.new.preload(instances, key)
      end

    end

    children = sources.map { |source| source.try(key) }.flatten.compact.uniq

    __prepare(children, value, data)

  end if query.present?

end


@source = @source.public_send(*@starter)


__prepare([@source].flatten, query, data)


data.each do |key, values|
  name = key.to_s.singularize
  json.set! key, values.flatten.compact.uniq do |value|
    json.partial! name, :"#{name}" => value[:model], :siblings => value[:siblings], cache: value[:cache], edges: value[:edges]
  end
end
