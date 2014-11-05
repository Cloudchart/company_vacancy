Dispatcher = require('dispatcher/dispatcher')
SyncAPI = require('sync/mixins/blockable_sync_api')


module.exports =


  createBlock: (key, attributes, token = 'create') ->
    Dispatcher.handleClientAction
      type: 'block:create'
      data: [key, attributes, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'block:create:done'
        data: [key, attributes, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'block:create:fail'
        data: [key, attributes, xhr.responseJSON, xhr, token]
    
    SyncAPI.createBlock(attributes.owner_id, attributes, done, fail)
