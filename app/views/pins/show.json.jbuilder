@__relations          = {}
@__included_relations = (params[:relations] || '').split(',').map(&:to_sym)

def should_include?(name)
  @__included_relations.include?(:all) or @__included_relations.include?(name)
end

def ensure_relation(name)
  @__relations[name] ||= []
end


case @pin.pinnable_type
when 'Post'
  load_pinnable_posts([@pin.pinnable_id], true).each do |key, values|
    ensure_relation(key).concat(values)
  end
end if should_include?(:pinnable)


json.pin do
  json.partial! 'pin', pin: @pin
end


# Render
#
@__relations.each do |key, values|
  partial_name = key.to_s.singularize
  json.set! key, values.uniq do |value|
    json.partial! partial_name, :"#{partial_name}" => value
  end
end
