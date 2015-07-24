module CloudGraph
  Schema = GraphQL::Schema.new query: CloudGraph::Types::Query, mutation: nil
end
