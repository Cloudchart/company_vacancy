module CloudApi
  module ApplicationHelper

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


  end
end
