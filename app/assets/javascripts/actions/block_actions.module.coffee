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
  

  # Update
  #
  # update: (key, attributes, token = 'update') ->
  #   Dispatcher.handleClientAction
  #     type: 'block:update'
  #     data: [key, attributes, token]
  #
  #   done = (json) ->
  #     Dispatcher.handleServerAction
  #       type: 'block:update:done'
  #       data: [key, json, token]
  #
  #   fail = (xhr) ->
  #     Dispatcher.handleServerAction
  #       type: 'block:update:fail'
  #       data: [key, xhr.responseJSON, xhr, token]
  #
  #   BlockSyncAPI.update(key, attributes, done, fail)
  #
  #
  # # Destroy
  # #
  # destroy: (key, token = 'destroy') ->
