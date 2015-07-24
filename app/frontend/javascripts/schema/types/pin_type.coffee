GraphQL = require('graphql')

{ GraphQLList, GraphQLNonNull, GraphQLObjectType, GraphQLString } = GraphQL

# Pin type
#
PinType = new GraphQLObjectType

  name: 'Pin'

  fields: ->
    id:
      type: GraphQLString
    content:
      type: GraphQLString
    created_at:
      type: GraphQLString
    pinboard:
      type: PinboardType
    user:
      type: UserType
    parent:
      type: PinType
    children:
      type: new GraphQLList(PinType)


# Exports
#
module.exports = PinType


# Types
#
UserType      = require('./user_type')
PinboardType  = require('./pinboard_type')
