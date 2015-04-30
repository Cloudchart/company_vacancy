# Utils
#
underscorize = (string) ->
  string.replace /[A-Z]/g, (char, index) -> (if index is 0 then '' else '_') + char.toLowerCase()


# Connection
#
class Connection

  constructor: (@path) ->
    Object.defineProperty @, 'node', get: => @_node ||= require(@path)


# Exports
#
module.exports = Connection
