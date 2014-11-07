# Imports
#
Dispatcher = require('dispatcher/dispatcher')
SyncAPI = require('sync/post_sync_api')
BlockableActions = require('actions/mixins/blockable_actions')

# Exports
#
Actions = 

  # TODO: write base CRUD, something like only: [:create, :update, :destroy]

  create: (key, attributes, sync_token = 'create') ->
    Dispatcher.handleClientAction
      type: 'post:create'
      data: [key, attributes, sync_token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'post:create:done'
        data: [key, attributes, json, sync_token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'post:create:fail'
        data: [key, attributes, xhr.responseJSON, xhr, sync_token]
    
    SyncAPI.create(attributes.owner_id, attributes, done, fail)


  update: (key, attributes, sync_token = 'update') ->
    Dispatcher.handleClientAction
      type: 'post:update'
      data: [key, attributes, sync_token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'post:update:done'
        data: [key, attributes, json, sync_token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'post:update:fail'
        data: [key, attributes, xhr.responseJSON, xhr, sync_token]
    
    SyncAPI.update(key, attributes, done, fail)


  destroy: (key, attributes, sync_token = 'destroy') ->
    Dispatcher.handleClientAction
      type: 'post:destroy'
      data: [key, attributes, sync_token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'post:destroy:done'
        data: [key, attributes, json, sync_token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'post:destroy:fail'
        data: [key, attributes, xhr.responseJSON, xhr, sync_token]
    
    SyncAPI.destroy(key, attributes, done, fail)


# Exports
# 
module.exports = _.extend Actions, BlockableActions
