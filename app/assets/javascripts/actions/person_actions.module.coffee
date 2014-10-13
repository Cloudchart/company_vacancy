# Imports
#
CloudFlux       = require('cloud_flux')
PersonSyncAPI   = require('sync/person_sync_api')


Module = CloudFlux.createActions

  
  create: (key, attributes, token = 'create') ->
    { clientAction, serverDoneAction, serverFailAction } = @createClientServerActions('person:create-', arguments...)

    clientAction()
    PersonSyncAPI.create(attributes['company_id'], attributes, serverDoneAction, serverFailAction)
    


  update: (key, attributes, token = 'update') ->
    { clientAction, serverDoneAction, serverFailAction } = @createClientServerActions('person:update-', arguments...)

    clientAction()
    PersonSyncAPI.update(key, attributes, serverDoneAction, serverFailAction)
    

# Exports
#
module.exports = Module
