# json.post   ams(@post)
# json.owner  ams(@post.owner)

relations = begin
  eval(params[:relations])
rescue SyntaxError, TypeError
  []
end


@__data = {}


def __ensure(key)
  @__data[key] ||= []
end


def traverse(object, relations = [])
  assocs = object.class.reflect_on_all_associations

  case relations
  when Symbol
    assoc = assocs.find { |a| a.name == relations }
    data  = object.public_send(relations)
    data  = [data] unless assoc.collection?
    data  = data.to_a.compact
    __ensure(data.first.class.name.pluralize.underscore.to_sym).concat(data)
    data

  when Hash
    relations.each do |relation, values|
      assoc = assocs.find { |a| a.name == relation }
      data  = object.public_send(relation)
      data  = [data] unless assoc.collection?
      data  = data.to_a.compact
      __ensure(data.first.class.name.pluralize.underscore.to_sym).concat(data)
      data

      data.each do |item|
        traverse(item, values)
      end
    end
  when Array
    relations.each do |relation|
      traverse(object, relation)
    end
  end
end


post = Post.includes(relations).find(params[:id])

__ensure(:posts) << post
traverse(post, relations)


@__data.each do |k, vs|
  name = k.to_s.singularize
  json.set! k, vs.flatten.compact.uniq do |v|
    json.partial! name, :"#{name}" => v
  end
end
