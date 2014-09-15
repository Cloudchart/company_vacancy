# Imports
#
Dispatcher = require('dispatcher/dispatcher')


# UUID
#
uuid = -> blobURL = URL.createObjectURL(new Blob) ; URL.revokeObjectURL(blobURL) ; blobURL.split('/').pop()


# Parse server data
#
parseServerData = (attributes = {}) ->
  uuid:         attributes['uuid']
  name:         attributes['name']
  data:         attributes['data']
  owner_id:     attributes['owner_id']
  owner_type:   attributes['owner_type']
  created_at:   Date.parse(attributes['created_at'])
  updated_at:   Date.parse(attributes['updated_at'])


# Parse client data
#
parseClientData = (attributes = {}) ->
  uuid:         attributes['uuid']
  name:         attributes['name']
  data:         attributes['data']
  owner_id:     attributes['owner_id']
  owner_type:   attributes['owner_type']


# Variables
#
data = {}


KnownAttributes = ['uuid', 'name', 'data', 'owner_id', 'owner_type', 'created_at', 'updated_at']


data = new Immutable.Vector


# Main
#
Store =
  
  build: (attributes = {}) ->
    key               = uuid()
    attributes        = parseClientData(attributes)
    attributes.__key  = attributes
    model             = Immutable.fromJS(attributes)
    data              = data.push(model)
    model


# Dispatching
#
Store.dispatchToken = Dispatcher.register (payload) ->
  action = payload.action      


# Exports
#
module.exports = Store
