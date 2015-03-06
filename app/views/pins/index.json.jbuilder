@__relations          = {}
@__included_relations = (params[:relations] || '').split(',').map(&:to_sym)

def should_include?(name)
  @__included_relations.include?(:all) or @__included_relations.include?(name)
end

def ensure_relation(name)
  @__relations[name] ||= []
end


# Pins
#
ensure_relation(:pins).concat(@pins)
ensure_relation(:pins).concat(@pins.map(&:parent).compact)


# Users
#
ensure_relation(:users).concat(User.includes(:emails).find(ensure_relation(:pins).map(&:user_id).compact.uniq))


# Pinnables
#
if should_include?(:pinnables)
  @pins.group_by(&:pinnable_type).each do |pinnable_type, pins|
  
    case pinnable_type
    when 'Post'
      
      load_pinnable_posts(pins.map(&:pinnable_id), true).each do |key, values|
        ensure_relation(key).concat(values)
      end
    
    end

  end
end


# Render
#
@__relations.each do |key, values|
  partial_name = key.to_s.singularize
  json.set! key, values.uniq do |value|
    json.partial! partial_name, :"#{partial_name}" => value
  end
end
