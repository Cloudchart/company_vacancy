module Schema

  UserType = GraphQL::GraphQLObjectType.new do
    name 'User'

    field :id, !GraphQL::GraphQLID
    field :full_name, !GraphQL::GraphQLString


    field :url,    !GraphQL::GraphQLString, resolve: -> (root) { "/users/#{root.slug || root.id}" }

    field :avatar,  GraphQL::GraphQLString do
      arg :size, !GraphQL::GraphQLInt
      resolve lambda { |root, params|
        size = params[:size]
        root.avatar.thumb("#{size}x#{size}#").url if root.avatar_stored?
      }
    end


    field :featured_collections, -> { + CollectionType } do
      arg :scope, !GraphQL::GraphQLString
      resolve lambda { |root, params, context|
        Storage::Collection.featured_collections(params[:scope])
      }
    end

    field :super_featured_collections, -> { + CollectionType } do
      arg :scope, !GraphQL::GraphQLString
      resolve lambda { |root, params, context|
        Storage::Collection.super_featured_collections(params[:scope])
      }
    end

    field :featured_users, -> { + UserType } do
      arg :scope, !GraphQL::GraphQLString
      resolve lambda { |root, params, context|
        Storage::UserStorage.featured(params[:scope])
      }
    end

  end

end
