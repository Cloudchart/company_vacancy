# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
RolesStore  = require('stores/roles')
Constants   = require('constants')
RoleSync    = require('sync/role')


# Exports
#
module.exports =

  update: (key, attributes, token = 'update') ->
    Dispatcher.handleClientAction
      type: Constants.Role.UPDATE
      data: [key, attributes, token]
    
    record = RolesStore.get(key)

    done = (json) ->
      Dispatcher.handleServerAction
        type: Constants.Role.UPDATE_DONE
        data: [key, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: Constants.Role.UPDATE_FAIL
        data: [key, xhr.responseJSON, xhr, token]

    RoleSync.update(record.uuid, attributes, done, fail)
  

  # delete
  #
  delete: (key, token = 'delete') ->
    Dispatcher.handleClientAction
      type: Constants.Role.DELETE
      data: [key, token]
    
    record = RolesStore.get(key)

    done = (json) ->
      Dispatcher.handleServerAction
        type: Constants.Role.DELETE_DONE
        data: [key, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: Constants.Role.DELETE_FAIL
        data: [key, xhr.responseJSON, xhr, token]

    RoleSync.delete(record.uuid, done, fail)
