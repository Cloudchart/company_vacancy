RelayFetcher  = require('../../relay/fetcher')
PinType       = require('../types/pin_type')


{ GraphQLNonNull, GraphQLString } = require('graphql')


# Exports
#
module.exports =
  type: PinType
  args:
    id:
      type: new GraphQLNonNull(GraphQLString)

  resolve: (root, params = {}, _, query) ->
    RelayFetcher.fetch('Pin', query, params)
