# Imports
#
Dispatcher      = require('dispatcher/dispatcher')
PersonSyncAPI   = require('sync/person_sync_api')
PersonStore     = require('stores/person')


getActions = (type, args...) ->

  init  = _.initial(args)
  last  = _.last(args)

  client: ->
    Dispatcher.handleClientAction
      type: type
      data: args

  done: (json) ->
    Dispatcher.handleServerAction
      type: "#{type}:done"
      data: [init..., json, last]
  
  fail: (xhr) ->
    Dispatcher.handleServerAction
      type: "#{type}:fail"
      data: [init..., xhr.responseJSON, xhr, last]


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
  
  
  update: (key, attributes, token = 'update') ->
    { client, done, fail } = getActions('person:update-', key, attributes, token)

    client()
    PersonSyncAPI.update(key, attributes, done, fail)
    


# Exports
#
module.exports = Module
