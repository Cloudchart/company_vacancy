# Imports
#
Dispatcher      = require('dispatcher/dispatcher')
PictureStore    = require('stores/picture_store')
PictureSyncAPI  = require('sync/picture_sync_api')


# Exports
#
module.exports = 
  

  # Create
  #
  create: (block_key, attributes, token = 'create') ->
    key = PictureStore.create(attributes)
    
    Dispatcher.handleClientAction
      type: 'picture:create'
      data: [key, attributes, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'picture:create:done'
        data: [key, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'picture:create:fail'
        data: [key, xhr.respondeJSON, xhr, token]
    
    PictureSyncAPI.create(block_key, attributes, done, fail)
    
    
    key
    
    
  # Update
  #
  update: (key, attributes, token = 'create') ->
    record = PictureStore.get(key)
    
    Dispatcher.handleClientAction
      type: 'picture:update'
      data: [key, attributes, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'picture:update:done'
        data: [key, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'picture:update:fail'
        data: [key, xhr.respondeJSON, xhr, token]
    
    PictureSyncAPI.update(record.owner_id, attributes, done, fail)


  # Destroy
  #
  destroy: (key, token = 'destroy') ->
    record = PictureStore.get(key)
    
    Dispatcher.handleClientAction
      type: 'picture:destroy'
      data: [key, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'picture:destroy:done'
        data: [key, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'picture:destroy:fail'
        data: [key, xhr.responseJSON, xhr, token]
    
    PictureSyncAPI.destroy(record.owner_id, done, fail)
