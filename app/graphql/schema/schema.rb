module Schema

  require_relative 'user_type'
  require_relative 'collection_type'
  require_relative 'query_type'

  Schema = GraphQL::GraphQLSchema.new do
    name 'CloudchartSchema'

    query QueryType
  end

end
