GraphQL = require('graphql')

{ GraphQLInt, GraphQLList, GraphQLNonNull, GraphQLObjectType, GraphQLString } = GraphQL


# Avatar type
#
AvatarType = new GraphQLObjectType

  name: 'Avatar'

  fields: ->
    url:
      type: GraphQLString


# User type
#
UserType = new GraphQLObjectType

  name: 'User'

  fields: ->
    id:
      type: GraphQLString
    full_name:
      type: GraphQLString
    url:
      type: GraphQLString
    avatar:
      type: AvatarType
    insights:
      type: new GraphQLList(PinType)
    pinboards:
      type: new GraphQLList(PinboardType)
    related_pinboards:
      type: new GraphQLList(PinboardType)


# Exports
#
module.exports = UserType


# Types
#
PinType       = require('./pin_type')
PinboardType  = require('./pinboard_type')
