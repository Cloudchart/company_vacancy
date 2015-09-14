module Schema

  QueryType = GraphQL::GraphQLObjectType.new do
    name 'QueryType'

    # Viewer
    #
    field :viewer, -> { !UserType } do
      resolve -> (root) { root[:viewer] }
    end

  end

end
