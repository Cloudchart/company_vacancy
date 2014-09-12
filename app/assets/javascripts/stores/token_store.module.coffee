# Imports
#
Dispatcher = require('dispatcher/dispatcher')


# Variables
#
data = {}


KnownAttributes = ['uuid', 'name', 'data', 'owner_id', 'owner_type', 'created_at', 'updated_at']


# Main
#
Store =


  find: (predicate) ->
    if _.isFunction(predicate) then _.find(data, predicate) else @find((item) -> item.uuid == predicate)


# Exports
#
module.exports = Store
