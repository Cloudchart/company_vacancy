# Imports
#
CloudFlux = require('cloud_flux')
Dispatcher = require('dispatcher/dispatcher')
SyncAPI = require('sync/person_sync_api')


Module = CloudFlux.createActions

  
  create: (key, attributes, token = 'create') ->
    Dispatcher.handleClientAction
      type: 'person:create-'
      data: [key, attributes, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'person:create-:done'
        data: [key, attributes, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'person:create-:fail'
        data: [key, attributes, xhr.responseJSON, xhr, token]
    
    SyncAPI.create(attributes.company_id, attributes, done, fail)


  update: (key, attributes, token = 'update') ->
    Dispatcher.handleClientAction
      type: 'person:update-'
      data: [key, attributes, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'person:update-:done'
        data: [key, attributes, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'person:update-:fail'
        data: [key, attributes, xhr.responseJSON, xhr, token]
    
    SyncAPI.update(key, attributes, done, fail)
    

# Exports
#
module.exports = Module
