# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
SyncAPI     = require('sync/company')


# Exports
#
module.exports =
  

  fetchAccessRights: (key, token) ->
    Dispatcher.handleClientAction
      type: 'company:access_rights:fetch'
      data: [key, token]
    

    done = (json) ->
      Dispatcher.handleServerAction
        type: 'company:access_rights:fetch:done'
        data: [key, json, token]
    

    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'company:access_rights:fetch:fail'
        data: [key, xhr.responseJSON, xhr, token]
    

    SyncAPI.fetchAccessRights(key, done, fail)
