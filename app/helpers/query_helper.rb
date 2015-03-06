module QueryHelper


  def parse_relations_query(query)
    return {} if query.nil? or query.blank?

    result    = {}
    key       = ''
    count     = 0
    subquery  = ''

    query.each_char do |char|
      case char
      when '{'
        subquery += char if count > 0
        count += 1
      when '}'
        count -= 1
        subquery += char if count > 0

        if count == 0
          result[key] = parse_relations_query(subquery)
          subquery = ''
        end
      when ','
        if count > 0
          subquery += char
        else
          result[key] = nil unless result[key]
          key         = ''
        end
      else
        if count > 0
          subquery += char
        else
          key += char
        end
      end
    end

    result[key] = nil unless result[key]

    result
  end


  def build_relations_includes(data)
    result = []

    data.each do |k, v|
      if v
        result.push({})
        result.last[k.to_sym] = build_relations_includes(v)
      else
        result.push(k.to_sym)
      end
    end

    result
  end


  def traverse_relations(object, relations, data = {})
    relations.each do |key, value|
      association = object.class.reflect_on_association(key.to_sym)
      items       = object.public_send(key)
      items       = [items] unless association.collection?
      items       = items.to_a.compact.uniq

      items.each do |item|
        (data[item.class.name.pluralize.underscore.to_sym] ||= []) << item
        traverse_relations(item, value, data) unless value.nil?
      end
    end
  end


  def render_jbuilder_objects(json, data)
    data.each do |key,values|
      name = key.to_s.singularize
      json.set! key, values.flatten.compact.uniq do |value|
        json.partial! name, :"#{name}" => value
      end
    end
  end

end
