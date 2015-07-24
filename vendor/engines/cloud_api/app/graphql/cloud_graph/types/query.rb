module CloudGraph
  module Types
    Query = GraphQL::ObjectType.new do |i, t, f|

      i.name "User"

      i.fields = {

        user: CloudGraph::Fields::UserField

      }

    end
  end
end
