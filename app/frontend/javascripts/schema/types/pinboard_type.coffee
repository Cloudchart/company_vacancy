GraphQL = require('graphql')

{ GraphQLInt, GraphQLList, GraphQLNonNull, GraphQLObjectType, GraphQLString } = GraphQL

# Pinboard type
#
PinboardType = new GraphQLObjectType

  name: 'User'

  fields: ->
    id:
      type: GraphQLString
    title:
      type: GraphQLString
    description:
      type: GraphQLString
    pins:
      type: new GraphQLList(PinType)
    pins_count:
      type: GraphQLInt
    user:
      type: UserType


# Exports
#
module.exports = PinboardType


# Types
#
PinType   = require('./pin_type')
UserType  = require('./user_type')
