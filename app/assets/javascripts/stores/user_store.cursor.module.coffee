# Imports
#
GlobalState = require('global_state/state')


# Exports
#
module.exports = GlobalState.createStore
  
  displayName:    'UserStore'


  collectionName: 'users'
  instanceName:   'user'
  
  
  syncAPI: require('sync/user_sync_api')
  

  serverActions: ->
    'post:fetch-all:done': @populate
