# Imports
#
Dispatcher = require('dispatcher/dispatcher')


# UUID
#
uuid = -> blobURL = URL.createObjectURL(new Blob) ; URL.revokeObjectURL(blobURL) ; blobURL.split('/').pop()


# Filter Attributes
#
filterAttributes = (attributes = {}) ->
  _.reduce KnownAttributes, ((memo, attribute) -> memo[attribute] = attributes[attribute] ; memo), {}


# Variables
#
data = {}


KnownAttributes = ['uuid', 'name', 'data', 'owner_id', 'owner_type', 'created_at', 'updated_at']


data = new Immutable.Sequence


# Main
#
class Store
  
  @build: (attributes = {}) ->
    key               = uuid()
    attributes        = filterAttributes(attributes)
    attributes.__key  = attributes
    model             = new Immutable.Map(attributes)
    data = data.push(model)
    model


# Dispatching
#
Store.dispatchToken = Dispatcher.register (payload) ->
  action = payload.action      


# Exports
#
module.exports = Store
