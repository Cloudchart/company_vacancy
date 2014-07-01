module Cloudchart::Utils

  def self.tokenized_query_string(query, attributes)
    tokens = query.split(/\s+/)

    attributes = if attributes.is_a?(Array)
      attributes
    else
      [].push(attributes)
    end

    if tokens.size > 1
      default_operator = attributes.size > 1 ? ' OR ' : ' AND '

      attributes.map do |attribute| 
        "(#{tokens.map { |token| "#{attribute}:#{token}" }.join(default_operator)})"
      end.join(' AND ')
    else
      attributes.map { |attribute| "#{attribute}:#{query}" }.join(' OR ')
    end
  end  

end
