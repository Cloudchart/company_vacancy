# Imports
#
Dispatcher      = require('dispatcher/dispatcher')
PersonSyncAPI   = require('sync/person_sync_api')
PersonStore     = require('stores/person')


# Main
#
Module =
  
  create: (key, attributes, token = 'create') ->
    Dispatcher.handleClientAction
      type: 'person:create-'
      data: [key, attributes, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'person:create:done-'
        data: [key, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'person:create:fail-'
        data: [key, xhr.responseJSON, xhr, token]
    
    record = PersonStore.get(key)
    
    PersonSyncAPI.create(record.company_id, attributes, done, fail)


# Exports
#
module.exports = Module
