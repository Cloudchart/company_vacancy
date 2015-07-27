# Imports
#
{ GraphQLSchema, GraphQLObjectType } = require('graphql')


# Exports
#
module.exports = new GraphQLSchema

  query: new GraphQLObjectType
    name: 'Query'
    fields: ->
      User: UserField
      Pin:  PinField


# Fields import
#
UserField = require('./queries/user_field')
PinField  = require('./queries/pin_field')
