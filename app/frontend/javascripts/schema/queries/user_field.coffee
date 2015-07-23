RelayFetcher  = require('../../relay/fetcher')
UserType      = require('../types/user_type')

{ GraphQLNonNull, GraphQLString } = require('graphql')

# Exports
#
module.exports =
  type: UserType
  args:
    id:
      type: new GraphQLNonNull(GraphQLString)

  resolve: (root, params = {}, _, query) ->
    RelayFetcher.fetch('User', query, params)
