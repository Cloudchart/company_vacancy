module Schema

  InsightsConnection = Relay::Connection::CompositeType.new do
    name 'Insights'

    nodeType -> { InsightType }

    connectionField :count, !GraphQL::GraphQLInt, resolve: -> (root) { root.size }
  end

  CollectionType = GraphQL::GraphQLObjectType.new do
    name 'Collection'

    field :id,    !GraphQL::GraphQLID
    field :title, !GraphQL::GraphQLString

    field :url, !GraphQL::GraphQLString do
      resolve -> (collection) { "/collections/#{collection.id}" }
    end

    field :insights, InsightsConnection.connectionType do
      args Relay::Connection::ConnectionArguments

      resolve lambda { |collection, params|
        # Relay::Connection.fromArray(Storage::Collection.insights(collection.id), params)
        Relay::Connection.fromArray([], params)
      }
    end
  end

end
