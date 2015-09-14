module Schema

  InsightType = GraphQL::GraphQLObjectType.new do
    name 'Insight'

    field :id, !GraphQL::GraphQLID
    field :content, !GraphQL::GraphQLString

    field :url, !GraphQL::GraphQLString do
      resolve lambda { |root|
        "/insights/#{root.id}"
      }
    end

    field :user, -> { !UserType } do
      resolve lambda { |root|
        Storage::UserStorage.find(root.user_id)
      }
    end

  end

end
