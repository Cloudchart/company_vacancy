##= require dispatcher/dispatcher.module
##= require utils/person_sync_api.module


# Imports
#
Dispatcher    = require('dispatcher/dispatcher')
PersonSyncAPI = require('utils/person_sync_api')


# Actions
#
actions =
  
  
  create: (company, model, attributes) ->
    Dispatcher.handleClientAction
      type:       'person:create'
      model:      model
      attributes: attributes

    PersonSyncAPI.create(company, model)
  

  update: (key, attributes = {}) ->
    Dispatcher.handleClientAction
      type:       'person:update'
      key:        key
      attributes: attributes
    
    PersonSyncAPI.update(key)


# Exports
#
module.exports = actions
