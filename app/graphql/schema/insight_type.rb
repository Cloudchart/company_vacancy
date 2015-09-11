module Schema

  InsightType = GraphQL::GraphQLObjectType.new do
    name 'Insight'

    field :id, !GraphQL::GraphQLID
    field :content, !GraphQL::GraphQLString

  end

end
