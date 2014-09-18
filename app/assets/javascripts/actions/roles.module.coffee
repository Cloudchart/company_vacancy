# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
SyncAPI     = require('sync/roles')


# Exports
#
module.exports =
  

  # Revoke
  #
  revoke: (company_key, key, token) ->
    Dispatcher.handleClientAction
      type: 'role:revoke'
      data: [key, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'role:revoke:done'
        data: [key, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'role:revoke:fail'
        data: [key, xhr.responseJSON, xhr, token]
    
    SyncAPI.revoke(company_key, key, done, fail)
