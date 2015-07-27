Storage = require('../../relay/storage')
PinType = require('../types/pin_type')


{ GraphQLNonNull, GraphQLString } = require('graphql')


# Exports
#
module.exports =
  type: PinType
  args:
    id:
      type: new GraphQLNonNull(GraphQLString)

  resolve: (root, params, _, query) ->
    Storage.fetch(root, params, query)
