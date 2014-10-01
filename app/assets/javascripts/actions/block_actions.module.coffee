# Imports
#
Dispatcher      = require('dispatcher/dispatcher')
BlockSyncAPI    = require('sync/block_sync_api')


# Exports
#
module.exports =
  
  
  # Update
  #
  update: (key, attributes, token = 'update') ->
    Dispatcher.handleClientAction
      type: 'block:update'
      data: [key, attributes, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'block:update:done'
        data: [key, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'block:update:fail'
        data: [key, xhr.responseJSON, xhr, token]
    
    BlockSyncAPI.update(key, attributes, done, fail)
