{ GraphQLSchema, GraphQLObjectType } = require('graphql')

module.exports = new GraphQLSchema

  query: new GraphQLObjectType
    name: 'Query'
    fields: ->
      User: require('./queries/user_field')
      Pin:  require('./queries/pin_field')
