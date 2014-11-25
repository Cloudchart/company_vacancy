# Imports
#
Dispatcher = require('dispatcher/dispatcher')
SyncAPI = require('sync/block_sync_api')
ActionFactory = require('actions/factory')

CrudActions = ActionFactory.create 'block',
  'update': (id, attributes) -> SyncAPI.update(id, attributes)
  'destroy': (id) -> SyncAPI.destroy(id)

CustomActions = {

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
      
    SyncAPI.reposition(key, ids, done, fail)

}

# Exports
#
module.exports = _.extend CustomActions, CrudActions
