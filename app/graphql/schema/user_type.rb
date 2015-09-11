module Schema

  UserType = GraphQL::GraphQLObjectType.new do
    name 'User'

    field :full_name, !GraphQL::GraphQLString

    field :featured_collections, -> { + CollectionType } do
      arg :scope, !GraphQL::GraphQLString
      resolve lambda { |root, params, context|
        Rails.logger.info "PARAMS: #{params}"
        Storage::Collection.featured_collections(params[:scope])
      }
    end
  end

end
