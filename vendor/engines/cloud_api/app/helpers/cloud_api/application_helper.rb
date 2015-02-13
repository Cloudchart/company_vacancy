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


    def populate_data_for_jbuilder(memo, source, query)
      return if source.nil?

      if source.respond_to?(:each)
        source.each do |child|
          populate_data_for_jbuilder(memo, child, query)
        end
      else
        (memo[source.class.name.pluralize.underscore.to_sym] ||= []) << source

        query.each do |child, child_query|
          populate_data_for_jbuilder(memo, source.public_send(child), child_query)
        end unless query.nil?
      end
    end


  end
end