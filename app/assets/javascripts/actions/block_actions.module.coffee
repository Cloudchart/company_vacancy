# Imports
#
CloudFlux       = require('cloud_flux')
Dispatcher      = require('dispatcher/dispatcher')
BlockSyncAPI    = require('sync/block_sync_api')


# Exports
#
module.exports = CloudFlux.createActions
  
  update: (key, attributes, token = 'update') ->
    actions = @createClientServerActions('block:update', arguments...)

    actions.clientAction()

    BlockSyncAPI.update(key, attributes, actions.serverDoneAction, actions.serverFailAction)
  
  
  destroy: (key, token = 'destroy') ->
    actions = @createClientServerActions('block:destroy', arguments...)

    actions.clientAction()

    BlockSyncAPI.destroy(key, actions.serverDoneAction, actions.serverFailAction)
  

  reposition: (key, ids, token = 'reposition') ->
    Dispatcher.handleClientAction
      type: 'blocks:reposition'
      data: [key, ids, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'blocks:reposition:done'
        data: [key, ids, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'blocks:reposition:fail'
        data: [key, ids, xhr.responseJSON, xhr, token]
      
    BlockSyncAPI.reposition(key, ids, done, fail)
