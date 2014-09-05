##= require dispatcher/dispatcher.module
##= require utils/person_sync_api.module


# Imports
#
Dispatcher    = require('dispatcher/dispatcher')
PersonSyncAPI = require('utils/person_sync_api')


# Actions
#
actions = 

  update: (key, attributes = {}, shouldSync = false) ->
    Dispatcher.handleClientAction
      type:       'person:update'
      key:        key
      attributes: attributes
    
    PersonSyncAPI.update(key)


# Exports
#
module.exports = actions
