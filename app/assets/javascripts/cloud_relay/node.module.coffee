# Connection
#
Connection = require('cloud_relay/connection')


# Node
#
class Node

  displayName: 'Node'


  @_queries:      Immutable.List()
  @_connections:  Immutable.Map()


  @connection: (name, path) ->
    @_connections = @_connections.set(name, new Connection(path)) if path
    @_connections.get(name)


  @addQuery: (query) ->
    @_queries = @_queries.push(query) unless @_queries.contains(query)
    @_queries


# Exports
#
module.exports = Node
