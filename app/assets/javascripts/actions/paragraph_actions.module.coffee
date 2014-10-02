# Imports
#
Dispatcher        = require('dispatcher/dispatcher')
ParagraphStore    = require('stores/paragraph_store')
ParagraphSyncAPI  = require('sync/paragraph_sync_api')


# Exports
#
module.exports =
  
  update: (key, attributes, token = 'update') ->
    Dispatcher.handleClientAction
      type: 'paragraph:update'
      data: [key, attributes, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'paragraph:update:done'
        data: [key, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'paragraph:update:fail'
        data: [key, xhr.responseJSON, xhr, token]
    
    record = ParagraphStore.get(key)
    
    ParagraphSyncAPI.update(record.owner_id, attributes, done, fail)
  
  
  delete: (key, token = 'delete') ->
    Dispatcher.handleClientAction
      type: 'paragraph:delete'
      data: [key, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'paragraph:delete:done'
        data: [key, json, token]

    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'paragraph:delete:fail'
        data: [key, xhr.reposnseJSON, xhr, token]
    
    record = ParagraphStore.get(key)
    
    ParagraphSyncAPI.delete(record.owner_id, done, fail)
