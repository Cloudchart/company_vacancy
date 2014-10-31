# Imports
#
Dispatcher = require('dispatcher/dispatcher')
# SyncAPI = require('sync/post')
# Constants = require('constants')
Blockable = require('actions/mixins/blockable')

# Exports
#
Actions =

  create: (key, attributes, sync_token = 'create') ->
    Dispatcher.handleClientAction
      type: 'post:create'
      data: [key, attributes, sync_token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'post:create:done'
        data: [key, attributes, json, sync_token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'post:create:fail'
        data: [key, attributes, xhr.responseJSON, xhr, sync_token]
    
    # SyncAPI.create(attributes.owner_id, attributes, done, fail)


# Exports
# 
module.exports = _.extend Actions, Blockable
