module Cloudchart::Utils

  def self.tokenized_query_string(query, attributes, default_operator = nil)
    tokens = query.split(/\s+/)

    attributes = if attributes.is_a?(Array)
      attributes
    else
      [].push(attributes)
    end

    if tokens.size > 1
      default_operator = default_operator || attributes.size > 1 ? ' OR ' : ' AND '

      attributes.map do |attribute| 
        "(#{tokens.map { |token| "#{attribute}:#{token}" }.join(default_operator)})"
      end.join(' AND ')
    else
      attributes.map { |attribute| "#{attribute}:#{query}" }.join(' OR ')
    end
  end

  def self.uuid?(param)
    !!param.to_s.match(/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i)
  end

end
