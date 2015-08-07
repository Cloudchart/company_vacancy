data  = {}
query = parse_relations_query(params[:relations])


def current_user_ability
  @current_user_ability ||= Ability.new(current_user)
end


def __prepare(sources, query, data, json)
  grouped_sources = {}

  scope = { current_user: current_user, current_user_ability: current_user_ability, params: params }

  cache   = []
  edges   = (query || {}).delete('edges') { [] }
  edges   = edges.nil? ? [] : edges.flatten.compact.uniq.map(&:to_sym)

  sources.each do |source|
    (grouped_sources[source.class] ||= []) << source
    if source.respond_to?(:id)
      (data[source.class.name.underscore.pluralize] ||= []) << { model: source, siblings: sources, cache: cache, edges: edges }
    end
  end

  if sources.first.respond_to?(:id)
    json.type sources.first.class.name
    json.ids sources.map(&:id)
  end

  query.each do |key, value|

    children = []

    grouped_sources.each do |klass, instances|

      args        = []
      skip_scope  = false

      if klass.present? && klass.reflect_on_association(key)
        Preloadable::preload(instances, cache, key)
        skip_scope = true
      elsif klass.present? && klass.respond_to?(:"preload_#{key}")
        klass.public_send(:"preload_#{key}", instances, cache)
      end

      args << scope if !skip_scope && (method = klass.instance_method(key)) && method.parameters.size == 1

      child_instances = instances.map do |instance|
        result = instance.public_send(key, *args)
        json.set! instance.id do
          if result.respond_to?(:each)
            json.set! key, result.map(&:id)
          else
            json.set! key, result.id if result.respond_to?(:id)
          end
        end
        result
      end

      children.concat child_instances.flatten
    end

    json.set! key do
      __prepare(children.compact.uniq, value, data, json)
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
