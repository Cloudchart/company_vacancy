# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
Constants   = require('constants')
TagStore    = require('stores/tag_store')
TagSyncAPI  = require('sync/tag_sync_api')


# Exports
#
module.exports =


  # Fetch
  #
  fetch: (token = 'fetch') ->
    Dispatcher.handleClientAction
      type: Constants.Tag.FETCH
      data: [token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: Constants.Tag.FETCH_DONE
        data: [json, token]

    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: Constants.Tag.FETCH_DONE
        data: [xhr.responseJSON, xhr, token]

    TagSyncAPI.fetch(done, fail)
  
  
  # Create
  #
  create: (name, token = 'create') ->
    key = TagStore.create({ name: name })
    
    Dispatcher.handleClientAction
      type: Constants.Tag.CREATE
      data: [key, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: Constants.Tag.CREATE_DONE
        data: [key, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: Constants.Tag.CREATE_FAIL
        data: [key, xhr.reposneJSON, xhr, token]
    
    TagSyncAPI.create(TagStore.get(key).toJSON(), done, fail)  
    
    key
