# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
RolesStore  = require('stores/roles')
Constants   = require('constants')
CompanySync = require('sync/company')


# Exports
#
module.exports =
  

  # Revoke
  #
  revoke: (key, token = 'revoke') ->
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

    CompanySync.revokeRole(record.owner_id, record.uuid, done, fail)
