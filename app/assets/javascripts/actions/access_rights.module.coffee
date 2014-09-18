# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
SyncAPI     = require('sync/access_rights')


# Exports
#
module.exports =
  

  # Revoke
  #
  revoke: (company_key, key, token) ->
    Dispatcher.handleClientAction
      type: 'access_rights:revoke'
      data: [key, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'access_rights:revoke:done'
        data: [key, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'access_rights:revoke:fail'
        data: [key, xhr.responseJSON, xhr, token]
    
    SyncAPI.revoke(company_key, key, done, fail)
