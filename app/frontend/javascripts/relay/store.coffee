# Imports
#
GraphQL = require('graphql')
Schema  = require('../schema/schema')
Flyd    = require('flyd')

# Store
#
Store = Immutable.Map()


# Parse query
#
QueryRE = /^([_a-zA-Z][_a-zA-Z0-9]+)\s(\{.+\})$/

parseQuery = (query) ->
  query = query.replace(/\s+/g, ' ').trim()
  [_, endpoint, body] = QueryRE.exec(query)
  query = "query get#{endpoint}($id: String!) { #{endpoint}(id: $id) #{body} }"

  endpoint: endpoint
  query:    query


# Get
#
get = (query, params) ->
  { query }     = parseQuery(query, params)
  stream        = Flyd.stream()
  graphqlQuery  = GraphQL.graphql(Schema, query, { stream: stream }, params)

  graphqlQuery.then (result) ->
    console.log 'store fetch done'
    console.log result

  stream


# Exports
#
module.exports =
  get: get
